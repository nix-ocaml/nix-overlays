{ buildDunePackage, mongo, lwt, mirage-crypto, gluten-lwt, pbkdf, base64 }:

buildDunePackage {
  pname = "mongo-lwt";
  inherit (mongo) src version;

  propagatedBuildInputs = [ mongo lwt mirage-crypto gluten-lwt pbkdf base64 ];
}
