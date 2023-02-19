{
  nixConfig = {
    extra-substituters = "https://ocaml.nix-cache.com";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem =
        { config
        , self'
        , inputs'
        , pkgs
        , system
        , ...
        }: {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              alejandra.enable = true;
              ocamlformat = {
                inherit pkgs;
                configFile = ./.ocamlformat;
                enable = true;
              };
            };
          };

          packages = pkgs.ocamlPackages.callPackage ./nix {
            inherit (inputs) nix-filter;
            doCheck = true;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = with self'.packages; [
              self'.packages.package
            ];

            packages = with pkgs.ocamlPackages; [
              ocaml
              dune

              ocaml-lsp

              ocamlformat
              dune-release
              odoc
            ];
          };
        };
    };
}
