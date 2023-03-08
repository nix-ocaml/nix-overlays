{ fetchFromGitHub, lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "f70d9798332556e92a9b7eb245707305d437e6ee";
    hash = "sha256-YyH4AWXbljMK0dt8e+ptk1SD66v6tGXyUaKCc5yeumo=";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
