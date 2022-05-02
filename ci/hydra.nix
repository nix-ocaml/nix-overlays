{ pkgs, system }:
let
  filter = import ./filter.nix { inherit pkgs; };
in

with filter;
{
  build_4_12 = buildCandidates pkgs "4_12";
  build_4_13 = buildCandidates pkgs "4_13";
  build_4_14 = buildCandidates pkgs "4_14";
  build_5_00 = buildCandidates pkgs "5_00";

  arm64_4_13 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.aarch64-multiplatform-musl "4_13"
  else
    { });

  musl_4_13 = (if system == "x86_64-linux" then
    crossTarget pkgs.pkgsCross.musl64 "4_13"
  else
    { });
}
