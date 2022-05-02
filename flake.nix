{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=98000933d72a97632caf0db0027ea3eb2e5e7f29";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      patches = [ ./add-janestreet-packages-0_15.patch ];
      patchChannel = system: channel: patches:
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
      # NOTE(anmonteiro): One downside of using _just_ the overlay, e.g.
      # `import nixpkgs { overlays = this-flake.overlay.default; }` is that
      # you don't get the patched sources.
      hydraJobs = {
        x86_64-linux = (import ./ci/hydra.nix { pkgs = self.packages.x86_64-linux; system = "x86_64-linux"; });
        aarch64-darwin = (import ./ci/hydra.nix { pkgs = self.packages.aarch64-darwin; system = "aarch64-darwin"; });
      };
      overlays.default = (import ./overlay nixpkgs);
      makePkgs = { system, extraOverlays ? [ ], ... }@attrs:
        let channel = patchChannel system nixpkgs patches;
        in

        import channel ({
          inherit system;
          overlays = [ self.overlays.default ] ++ extraOverlays;
          config = {
            allowUnfree = true;
          };
        } // attrs);
    } // flake-utils.lib.eachDefaultSystem (system:
      rec {
        packages = self.makePkgs { inherit system; };
        legacyPackages = self.packages."${system}";
      });
}
