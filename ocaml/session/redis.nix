{ lib, buildDunePackage, redis-lwt, session }:

buildDunePackage {
  pname = "session-redis-lwt";
  inherit (session) src version;

  propagatedBuildInputs = [ redis-lwt session ];

  meta = {
    description = "A session manager for your everyday needs - Redis-specific support for Lwt";
    license = lib.licenses.bsd3;
  };
}
