{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=c04ef155994d060aceedf946eeba0ab756b19c01";
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
