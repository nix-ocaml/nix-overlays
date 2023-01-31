{ lib, fetchFromGitHub, buildDunePackage, uuidm, re, stdlib-shims }:

buildDunePackage {
  pname = "redis";
  version = "0.4";
  src = fetchFromGitHub {
    owner = "0xffea";
    repo = "ocaml-redis";
    rev = "v0.6";
    sha256 = "sha256-+q0fhWW/T/Q7Aof5cMDyVai/DyeMld/C9YEau6LN+J4=";
  };

  propagatedBuildInputs = [ uuidm re stdlib-shims ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
