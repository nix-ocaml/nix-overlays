{
  description = "ocaml-packages-overlay";

  nixConfig = {
    extra-substituters = "https://anmonteiro.nix-cache.workers.dev";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=0ad13a6833440b8e238947e47bea7f11071dc2b2";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = import ./overlay nixpkgs;
    in
    nixpkgs.lib.recursiveUpdate
      {
        lib = nixpkgs.lib;

        hydraJobs = builtins.listToAttrs (map
          (system: {
            name = system;
            value = import ./ci/hydra.nix {
              inherit system;
              pkgs = self.legacyPackages.${system};
            };
          })
          [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]);

        makePkgs = { system, extraOverlays ? [ ], ... }@attrs:
          let
            pkgs = import nixpkgs ({
              inherit system;
              overlays = [ overlay ];
              config = {
                allowUnfree = true;
              } // nixpkgs.lib.optionalAttrs (system == "x86_64-darwin") {
                config.replaceStdenv = { pkgs, ... }: pkgs.clang11Stdenv;
              };
            } // attrs);
          in
            /*
            You might read
            https://nixos.org/manual/nixpkgs/stable/#sec-overlays-argument and
            want to change this but because of how we're doing overlays we will
            be overriding any extraOverlays if we don't use `appendOverlays`
            */
          pkgs.appendOverlays extraOverlays;

        overlays.default = final: prev: overlay final prev;
      }
      (flake-utils.lib.eachDefaultSystem (system: {
        legacyPackages = self.makePkgs { inherit system; };
      }));
}
