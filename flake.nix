{
  description = "A small collection of nix expressions/overlays for ocaml";

  nixConfig = {
    extra-substituters = "https://anmonteiro.nix-cache.workers.dev";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=75169d683d42ed2f3ccd99c321850f0abda70cb0";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-parts
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      flake = {
        lib = nixpkgs.lib; # Why are we exposing this?

        templates = {
          default = {
            path = ./templates/default;
            description = "Template showcasing basic usage";
          };
          flake-parts = {
            path = ./templates/flake-parts;
            description = "Template showcasing usage with flake-parts";
          };
        };

        overlay = import ./overlay nixpkgs;
        overlays.default = self.overlay;

        hydraJobs = builtins.listToAttrs (map
          (system: {
            name = system;
            value = import ./ci/hydra.nix {
              inherit system;
              pkgs = self.legacyPackages.${system};
            };
          })
          [ "x86_64-linux" "aarch64-darwin" ]);
      };
      perSystem = { pkgs, ... }: {
        legacyPackages = pkgs.extend self.overlay;
        formatter = pkgs.nixpkgs-fmt;
      };
    };
}
