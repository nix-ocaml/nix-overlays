{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=37b6b161e536fddca54424cf80662bce735bdd1e";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      patchChannel = { system, channel }:
        let
          patches = [ ./add-janestreet-packages-0_15.patch ];
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
      hydraJobs = builtins.listToAttrs (map
        (system: {
          name = system;
          value = (import ./ci/hydra.nix {
            inherit system;
            pkgs = self.packages.${system};
          });
        })
        [ "x86_64-linux" "aarch64-darwin" ]);

      makePkgs = { system, extraOverlays ? [ ], ... }@attrs:
        let pkgs = import nixpkgs ({
          inherit system;
          overlays = [ self.overlays.${system}.default ];
          config.allowUnfree = true;
        } // attrs);
        in
          /*
            You might read https://nixos.org/manual/nixpkgs/stable/#sec-overlays-argument and want to change this
            but because of how we're doing overlays we will be overriding any extraOverlays if we don't use `appendOverlays`
          */
        pkgs.appendOverlays extraOverlays;
    } // flake-utils.lib.eachDefaultSystem (system:
      {
        packages = self.makePkgs { inherit system; };
        legacyPackages = self.packages.${system};

        overlays.default = (final: prev:
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
