{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=0b9843c3bcca2ac748db8b52659e6cad5c0fd794";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = (import ./default.nix nixpkgs);
  } // flake-utils.lib.eachDefaultSystem (system:
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
      channel = patchChannel system nixpkgs patches;
    in

    rec {
      packages = makePkgs { };
      legacyPackages = self.packages."${system}";
      makePkgs = attrs:
        import channel ({
          inherit system;
          overlays = [ self.overlays.default ];
          config = {
            allowUnfree = true;
          };
        } // attrs);
    }));
}
