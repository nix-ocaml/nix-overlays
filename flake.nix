{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=98bcd08cb1778d103bac1149621b3568014aadbd";
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
        import nixpkgs ({
          inherit system;
          overlays = [ self.overlays.${system}.default ] ++ extraOverlays;
          config.allowUnfree = true;
        } // attrs);
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
