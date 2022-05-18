{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=ff691ed9ba21528c1b4e034f36a04027e4522c58";
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
