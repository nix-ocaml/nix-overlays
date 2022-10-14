{ lib, buildDunePackage, uuidm, re, stdlib-shims }:

buildDunePackage {
  pname = "redis";
  version = "0.4";
  src = builtins.fetchurl {
    url = https://github.com/0xffea/ocaml-redis/archive/refs/tags/v0.6.tar.gz;
    sha256 = "10sknikzhl80rb9kihiylanxv27995a6sc1xajpcnsifnkk87qj9";
  };

  propagatedBuildInputs = [ uuidm re stdlib-shims ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
