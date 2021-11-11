{ callPackage, go_1_15 }:

{
  cockroachdb-21_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "21.1.8";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "04i2y8qzhipyrbvyqyjflmqrzzc9vl3ic22h09n777ha95x0r7b7";
    };
  });

  # cockroachdb-dev = callPackage ./generic.nix (rec {
  # go = go_1_16;
  # version = "21.2.0-rc.3";
  # src = builtins.fetchurl {
  # url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
  # sha256 = "010plyi4jdpayabckdz3vq8nw983mb76sz23pnlgyyxgkcbbhg2p";
  # };
  # extraDeps = [ git ];
  # });
}
