{ fetchFromGitHub, lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "212b6f6233bd60c4c2f9289ba0dd3d19e839ffd0";
    hash = "sha256-MpkS+tmrb3U6HqmXKiNsGZlz0dmaDsX4JGakCjFtwm4=";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
