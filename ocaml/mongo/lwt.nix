{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "mongo-lwt";
  inherit (bson) src version;

  propagatedBuildInputs = [ mongo lwt mirage-crypto gluten-lwt pbkdf base64 ];
}
