{
  description = "ocaml-packages-overlay";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils }: ({
    overlay = final: prev: (import ./default.nix) final prev;
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
