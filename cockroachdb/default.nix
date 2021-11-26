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
    version = "21.2.0";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v21.2.0.src.tgz";
      sha256 = "0h9fv0i72xkxzr743rm4rg69w7qj3fa2qgqk7rx181xvlwhsrgrs";
    };
    patches = [ ./makefile-redact-safe-patch.patch ];
  });
}
