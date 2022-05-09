{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=58585adbcd7fa9889d3d3731fc9c1766317dec77";
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
