{ callPackage, go_1_15, go_1_16, go_1_17 }:

{
  cockroachdb-21_1_x = callPackage ./generic.nix (rec {
    go = go_1_15;
    version = "21.1.12";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "116zzrwzs6sbkwvnxgs8aidqxhc5a3vrk3acbgdnjbyfxxrrkv8j";
    };
  });

  cockroachdb-21_2_x = callPackage ./generic.nix (rec {
    go = go_1_17;
    version = "21.2.3";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "1lyxkwyljg82dd8m5b18zbvli02znj2aq2yqf8bpbrsd1psv3m8w";
    };
    patches = [ ./makefile-redact-safe-patch.patch ];
  });
}
