{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=afb8c54d8463f5035f6ece71cb54ba899378680f";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      patches = [ ];
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
