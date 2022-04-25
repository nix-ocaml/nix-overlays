{
  description = "ocaml-packages-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = final: prev: (import ./default.nix nixpkgs) final prev;
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
    makePkgs = attrs: import ./boot.nix { inherit nixpkgs; } attrs;
  }));
}
