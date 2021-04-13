{ pkgs }:

with pkgs;

{
  cockroachdb-20_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "20.2.7";
    src = builtins.fetchurl
      {
        url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
        sha256 = "11jh7fyyp9acnp8z4vc38rc2391sjl5d4aij9pf61wl7bfaqyb79";
      };
  });

  cockroachdb-21_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "21.1.0-beta.3";
    src = builtins.fetchurl
      {
        url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
        sha256 = "1sx22a7ax7pxf6q4vcnjh6x5v5d85lq409axl4xwml7iiqln18mr";
      };
  });
}
