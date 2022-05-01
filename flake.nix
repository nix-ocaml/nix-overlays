{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d6b996030dd21c6509803267584b9aca3e133a07";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = (import ./default.nix nixpkgs);
  } // flake-utils.lib.eachDefaultSystem (system: {
    # Packages are using the flake
    packages = import nixpkgs {
      inherit system;
      overlays = [ self.overlays.default ];
      config = {
        allowUnfree = true;
      };
    };
    legacyPackages = self.packages."${system}";
    makePkgs = attrs: import ./boot.nix attrs;
  }));
}
