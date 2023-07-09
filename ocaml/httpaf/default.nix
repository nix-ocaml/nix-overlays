{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "d98b2f1cff67e81b09decc3da017f6cb82ffe458";
    hash = "sha256-CXkrTzEUVIMLrXL1g3h8L00kOoY5VEHeFGioH+uEp1g=";
  };
}
