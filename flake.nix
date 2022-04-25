{
  description = "ocaml-packages-overlay";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: ({
    overlays.default = final: prev: (import ./default.nix { inherit nixpkgs; }) final prev;
  } // flake-utils.lib.eachDefaultSystem (system: {
    packages = import ./boot.nix {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    legacyPackages = self.packages."${system}";
    makePkgs = attrs: import ./boot.nix attrs;
  }));
}
