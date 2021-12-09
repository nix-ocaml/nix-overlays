{ callPackage, go_1_15, go_1_16 }:

{
  cockroachdb-21_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "21.1.8";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "04i2y8qzhipyrbvyqyjflmqrzzc9vl3ic22h09n777ha95x0r7b7";
    };
  });

  cockroachdb-22_x = callPackage ./generic.nix (rec {
    go = go_1_16;
    version = "21.2.2";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v21.2.2.src.tgz";
      sha256 = "07qwqlyn6lbq1j6rf58hy0n2hmp46jm2s66qjsisb60g5ydmdb19";
    };
    patches = [ ./makefile-redact-safe-patch.patch ];
  });
}
