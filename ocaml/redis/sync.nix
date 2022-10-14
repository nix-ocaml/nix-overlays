{ lib, buildDunePackage, redis, ounit, containers, camlp-streams }:

buildDunePackage {
  pname = "redis-sync";
  inherit (redis) src version;

  propagatedBuildInputs = [ redis camlp-streams ];

  meta = {
    description = "Redis client (blocking)";
    license = lib.licenses.bsd3;
  };
}
