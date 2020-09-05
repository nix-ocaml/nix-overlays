{
  description = "ReScript tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };

    in {
      overlay = import ./default.nix;

      devShell.${system} = pkgs.mkShell {
        buildInputs = [ pkgs.bs-platform ];
      };
    };
}
