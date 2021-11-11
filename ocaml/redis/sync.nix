{ lib, buildDunePackage, redis, ounit, containers }:

buildDunePackage {
  pname = "redis-sync";
  inherit (redis) src version;

  propagatedBuildInputs = [ redis ];

  checkInputs = [ ounit containers ];

  meta = {
    description = "Redis client (blocking)";
    license = lib.licenses.bsd3;
  };
}
