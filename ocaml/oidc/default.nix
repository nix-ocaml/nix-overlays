{ fetchFromGitHub, lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "5859343";
    hash = "sha256-YyH4AWXbljMK0dt8e+ptk1SD66v6tGXyUaKCc5yeumo=";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
