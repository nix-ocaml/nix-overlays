{ lib, buildDunePackage, cookie, session }:

buildDunePackage {
  pname = "session-cookie";
  inherit (cookie) src version;

  propagatedBuildInputs = [ cookie session ];

  meta = {
    description = "Session handling based on Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
