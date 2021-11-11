{ lib, buildDunePackage, redis, lwt, ounit, containers }:

buildDunePackage {
  pname = "redis-lwt";
  inherit (redis) src version;

  propagatedBuildInputs = [ redis lwt ];

  checkInputs = [ ounit containers ];

  meta = {
    description = "Redis client (lwt interface)";
    license = lib.licenses.bsd3;
  };
}
