# Heavily inspired by https://github.com/cleverca22/hydra-configs
{ pulls ? ./simple-pr-dummy.json }:

let
  pkgs = import <nixpkgs> {};
  makeSpec = contents: builtins.derivation {
    name = "spec.json";
    system = "x86_64-linux";
    preferLocalBuild = true;
    allowSubstitutes = false;
    builder = "/bin/sh";
    args = [ (builtins.toFile "builder.sh" ''
      echo "$contents" > $out
    '') ];
    contents = builtins.toJSON contents;
  };
in
with pkgs.lib;
let
  defaults = {
    enabled = 1;
    hidden = false;
    keepnr = 1;
    schedulingshares = 20;
    checkinterval = 600;
    enableemail = false;
    emailoverride = "";
  };
  primary_jobsets = {
    nix-overlays = defaults // {
      keepnr = 2;
    schedulingshares = 100;
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