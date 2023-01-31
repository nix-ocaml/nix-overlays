{ fetchFromGitHub, lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "4bb30333412593b899dfdc9e740465b06efb317e";
    sha256 = "sha256-pU8mt40iElL02a0bDrjc5RL9mpatDL7GlhF464iauX0=";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
