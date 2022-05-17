# Heavily inspired by https://github.com/cleverca22/hydra-configs
{ pulls ? ./simple-pr-dummy.json }:

let
  pkgs = import <nixpkgs>{};
in with import ./hydra_lib.nix;
with pkgs.lib;
let
  defaults = {
    enabled = 1;
    hidden = false;
    keepnr = 10;
    schedulingshares = 100;
    checkinterval = 600;
    enableemail = false;
    emailoverride = "";
  };
  primary_jobsets = {
    nix-overlays = defaults // {
      description = "nix-overlays";
      flake = "github:anmonteiro/nix-overlays";
    };
  };
  pr_data = builtins.fromJSON (builtins.readFile pulls);
  makePr = num: info: {
    name = "nix-overlays-${num}";
    value = defaults // {
      description = "PR ${num}: ${info.title}";
      flake = "github:anmonteiro/nix-overlays/${info.head.ref}";
    };
  };
  pull_requests = listToAttrs (mapAttrsToList makePr pr_data);
  jobsetsAttrs = pull_requests // primary_jobsets;
in {
  jobsets = makeSpec jobsetsAttrs;
}