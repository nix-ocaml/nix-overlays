{ callPackage, go_1_16, go_1_17, buildGo116Module, buildGo117Module }:

{
  cockroachdb-21_1_x = callPackage ./generic.nix (rec {
    go = go_1_16;
    buildGoModule = buildGo116Module;
    version = "21.1.13";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "1npqh75w1x2jjmy512jxqlr4caam96lw74gfs8kdq0iaw6hkh3y2";
    };
  });

  cockroachdb-21_2_x = callPackage ./generic.nix (rec {
    go = go_1_17;
    buildGoModule = buildGo117Module;
    version = "21.2.5";
    src = builtins.fetchurl {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
      sha256 = "0a06vdyiwfdq7ycqw8ckwxx01f6xnbn8a1gmjkzls34m4px5yzzn";
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
