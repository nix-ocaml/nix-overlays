{ lib, fetchFromGitHub, buildDunePackage, uuidm, re, stdlib-shims }:

buildDunePackage rec {
  pname = "redis";
  version = "0.7";
  src = builtins.fetchurl {
    url = https://github.com/0xffea/ocaml-redis/releases/download/v0.7.1/redis-0.7.1.tbz;
    sha256 = "02llmcfjh8dplc456y8y3vvvslsdib1r679pn8baphfm8xn1zxqf";
  };

  propagatedBuildInputs = [ uuidm re stdlib-shims ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
