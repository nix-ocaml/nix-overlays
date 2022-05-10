{ pkgs, system }:
let
  filter = pkgs.callPackage ./filter.nix { };
in

with filter;
{
  # build_4_12 = buildCandidates { inherit pkgs; ocamlVersion = "4_12"; };
  build_4_13 = buildCandidates { inherit pkgs; ocamlVersion = "4_13"; };
  # build_4_14 = buildCandidates { inherit pkgs; ocamlVersion = "4_14"; };
  build_5_00 = buildCandidates { inherit pkgs; ocamlVersion = "5_00"; extraIgnores = ocaml5Ignores; };

  /*
    arm64_4_13 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.aarch64-multiplatform-musl "4_13"
    else
    { });

    musl_4_13 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.musl64 "4_13"
    else
    { }
    );
  */
}
