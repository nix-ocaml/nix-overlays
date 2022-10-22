{ pkgs, system }:
let
  filter = pkgs.callPackage ./filter.nix { };
  isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";
  extraIgnores = if isDarwin then filter.darwinIgnores else [ ];
in

with filter;
{
  build_4_14 = ocamlCandidates { inherit pkgs extraIgnores; ocamlVersion = "4_14"; };
  build_5_00 = ocamlCandidates { inherit pkgs; ocamlVersion = "5_0"; extraIgnores = extraIgnores ++ ocaml5Ignores; };

  arm64_4_14 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.aarch64-multiplatform-musl "4_14"
  else
    { });

  musl_4_14 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.musl64 "4_14"
  else
    { }
  );

}
