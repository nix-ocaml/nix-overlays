{ lib, buildDunePackage, cookie, session-cookie, lwt }:

buildDunePackage {
  pname = "session-cookie-lwt";
  inherit (cookie) src version;

  propagatedBuildInputs = [ session-cookie lwt ];

  meta = {
    description = "Session handling based on Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
