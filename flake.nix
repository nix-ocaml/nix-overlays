{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d6b996030dd21c6509803267584b9aca3e133a07";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = (import ./default.nix nixpkgs);
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      patches = [ ./add-janestreet-packages-0_15.patch ];
      systemArgs = if system == null then { } else { inherit system; };
      patchChannel = system: channel: patches:
        if patches == [ ]
        then channel
        else
          (import channel systemArgs).pkgs.applyPatches {
            name = "nixpkgs-patched";
            src = channel;
            patches = patches;
          };
      nixpkgs = (import ./sources.nix);
      channel = patchChannel system nixpkgs patches;
    in

    rec {
      packages = makePkgs { };
      legacyPackages = self.packages."${system}";
      makePkgs = attrs:
        import channel ({
          overlays = [ self.overlays.default ];
          config = {
            allowUnfree = true;
          };
        } // attrs // systemArgs);
    }));
}
