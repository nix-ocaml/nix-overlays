{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "0ddc76b7599a15cf5cc71ae39acf1585f21ed8d5";
    hash = "sha256-UfBcOCKHbdBJ5WKkHz9HJU4a7CRbR/1ei1ajVy8u6rg=";
  };
}
