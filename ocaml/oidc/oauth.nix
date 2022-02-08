{ lib, buildDunePackage, oidc, uri, yojson, logs, base64 }:

buildDunePackage {
  pname = "oauth";
  inherit (oidc) src version;

  propagatedBuildInputs = [ uri yojson logs base64 ];

}
