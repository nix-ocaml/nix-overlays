{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d33eace057c830a5c1b43914d1e4287f7db605bb";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = (import ./overlay nixpkgs);
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
