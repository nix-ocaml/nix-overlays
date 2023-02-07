{
  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

  outputs = { nixpkgs }:
    let
      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      ocamlVersion = final: prev: { ocamlPackages = prev.ocaml-ng.ocamlPackages_5_0; };

      forAllSystems = f:
        l.genAttrs supportedSystems (system:
          f system
            (nixpkgs.legacyPackages.${system}.extend ocamlVersion));
    in
    {
      packages = forAllSystems (_: pkgs: {
        default = pkgs.ocamlPackages.ocaml;
      });
    };
}
