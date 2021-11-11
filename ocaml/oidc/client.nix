{ lib, buildDunePackage, oidc, jose, uri, yojson, logs, piaf }:

buildDunePackage {
  pname = "oidc-client";
  inherit (oidc) src version;

  propagatedBuildInputs = [ oidc jose uri yojson logs piaf ];

  meta = {
    description = "OpenID Connect Relaying Party implementation built ontop of Piaf.";
    license = lib.licenses.bsd3;
  };
}
