{ fetchFromGitHub, lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "25858673662bf12488d0fdd2d96e9672285e3003";
    hash = "sha256-n/9PycLMtJ409xEAUQ6gq5S1ljiWr9CytwuYIB0p0+A=";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
