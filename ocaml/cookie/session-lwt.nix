{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "session-cookie-lwt";
  inherit (cookie) src version;

  propagatedBuildInputs = with ocamlPackages; [
    session-cookie
    lwt
  ];

  meta = {
    description = "Session handling based on Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
