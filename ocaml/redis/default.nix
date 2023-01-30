{ lib, buildDunePackage, uuidm, re, stdlib-shims }:

buildDunePackage {
  pname = "redis";
  version = "0.4";
  src = builtins.fetchurl {
    url = https://github.com/0xffea/ocaml-redis/archive/refs/tags/v0.6.tar.gz;
    sha256 = "1vam8x3090xyhhj132sd3av03m47j1fby3yqdwh2vyxf1p859yq2";
  };

  propagatedBuildInputs = [ uuidm re stdlib-shims ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
