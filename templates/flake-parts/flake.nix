{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { flake-parts
    , ocaml-overlay
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch_64-darwin" ];
      perSystem =
        { inputs'
        , pkgs
        , ...
        }:
        let
          ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_0;
        in
        {
          config = {
            _module.args.pkgs = (inputs'.nixpkgs.legacyPackages).extend ocaml-overlay.overlay;
            packages.default = ocamlPackages.ocaml;
          };
        };
    };
}
