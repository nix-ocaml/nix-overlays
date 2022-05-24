{ callPackage, go_1_17, buildGo117Module }:

{
  cockroachdb-21_2_x = callPackage ./generic.nix (rec {
    go = go_1_17;
    buildGoModule = buildGo117Module;
    version = "21.2.6";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "0jixsbgc5azkl91cpy4j49ipv8sm6y8897gdvs2nc8waflj7kkfr";
    };
    patches = [ ./makefile-redact-safe-patch.patch ];
  });

  cockroachdb-22_x = callPackage ./generic.nix (rec {
    go = go_1_17;
    buildGoModule = buildGo117Module;
    version = "22.1.0-alpha.1";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "0w3m2wsghrzss0cx8jcp5y4ph1zjpar6piz7p9l5n1fixz3pc7r8";
    };
    patches = [ ./makefile-redact-safe-patch.patch ];
  });
}
