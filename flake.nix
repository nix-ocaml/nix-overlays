{
  description = "ocaml-packages-overlay";

  nixConfig = {
    extra-substituters = "https://anmonteiro.nix-cache.workers.dev";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=250b695f41e0e2f5afbf15c6b12480de1fe0001b";
  };

  outputs = { self, nixpkgs }:
    let
      overlay = import ./overlay nixpkgs;
    in
    {
      lib = nixpkgs.lib;

      hydraJobs = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system: import ./ci/hydra.nix {
          inherit system;
          pkgs = self.legacyPackages.${system};
        });

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

      overlays.default = final: prev: if (prev ? __nix-ocaml-overlays-applied) then { } else overlay final prev;

      legacyPackages = nixpkgs.lib.genAttrs
        nixpkgs.lib.systems.flakeExposed
        (system: self.makePkgs { inherit system; });
    };
}
