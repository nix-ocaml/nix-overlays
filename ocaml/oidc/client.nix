{ lib, buildDunePackage, oidc, jose, uri, yojson, logs }:

buildDunePackage {
  pname = "oidc-client";
  inherit (oidc) src version;

  propagatedBuildInputs = [ oidc jose uri yojson logs ];
  postPatch = ''
    substituteInPlace oidc-client/dune --replace-fail "piaf" "piaf-lwt"
    substituteInPlace \
      oidc-client/Static.ml oidc-client/Static.mli \
      oidc-client/MicrosoftClient.mli \
      oidc-client/Dynamic.ml oidc-client/Dynamic.mli \
      oidc-client/Utils.ml oidc-client/Internal.ml  \
      --replace-fail "Piaf" "Piaf_lwt"
  '';

  meta = {
    description = "OpenID Connect Relaying Party implementation built ontop of Piaf.";
    license = lib.licenses.bsd3;
  };
}
