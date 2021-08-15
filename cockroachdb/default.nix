{ pkgs }:

with pkgs;

{
  cockroachdb-21_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "21.1.7";
    src = builtins.fetchurl
      {
        url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
        sha256 = "1br9139glgy954zjlgznc7ss9x19ssvm8lcm7w5037k1gnhdgiha";
      };
  });

  # cockroachdb-dev = callPackage ./generic.nix (rec {
  # go = go_1_15;
  # version = "21.2.0-alpha.1";
  # src = builtins.fetchurl
  # {
  # url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
  # sha256 = "";
  # };
  # });
}
