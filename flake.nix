{
  description = "ocaml-packages-overlay";

  nixConfig = {
    extra-substituters = "https://anmonteiro.nix-cache.workers.dev";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=ad83bff0088bcefd621fcf16b0db5d34f0cebf1c";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      patchChannel = { system, channel }:
        let
          patches = [ ];
        in
        if patches == [ ]
        then channel
        else
          (import channel { inherit system; }).pkgs.applyPatches {
            name = "nixpkgs-patched";
            src = channel;
            patches = patches;
          };
    in

    {
      lib = nixpkgs.lib;

      hydraJobs = builtins.listToAttrs (map
        (system: {
          name = system;
          value = (import ./ci/hydra.nix {
            inherit system;
            pkgs = self.legacyPackages.${system};
          });
        })
        [ "x86_64-linux" "aarch64-darwin" ]);

      makePkgs = { system, extraOverlays ? [ ], ... }@attrs:
        let
          pkgs = import nixpkgs ({
            inherit system;
            overlays = [ self.overlays.${system} ];
            config.allowUnfree = true;
          } // attrs);
        in
          /*
            You might read
            https://nixos.org/manual/nixpkgs/stable/#sec-overlays-argument and
            want to change this but because of how we're doing overlays we will
            be overriding any extraOverlays if we don't use `appendOverlays`
          */
        pkgs.appendOverlays extraOverlays;

      overlays.default = import ./overlay nixpkgs;
    } // flake-utils.lib.eachDefaultSystem (system:
      {
        legacyPackages = self.makePkgs { inherit system; };

        overlays = (final: prev:
          let
            channel = patchChannel {
              inherit system;
              channel = nixpkgs;
            };
          in

          import channel {
            inherit system;
            overlays = [ (import ./overlay channel) ];
            config.allowUnfree = true;
          }
        );
      });
}
