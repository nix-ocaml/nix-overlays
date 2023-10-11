{ lib, fetchFromGitHub, buildDunePackage, uuidm, re, stdlib-shims }:

buildDunePackage rec {
  pname = "redis";
  version = "0.6";
  src = builtins.fetchurl {
    url = https://github.com/0xffea/ocaml-redis/releases/download/v0.7/redis-0.7.tbz;
    sha256 = "1irrld5f9x0yd9ikmj65fgnnjz64m24ddqjk2vnx8s2jvwrrjgi8";
  };

  propagatedBuildInputs = [ uuidm re stdlib-shims ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
