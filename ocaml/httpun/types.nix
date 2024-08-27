{ fetchFromGitHub, buildDunePackage, faraday }:

buildDunePackage {
  version = "0.1.0-dev";
  pname = "httpun-types";
  propagatedBuildInputs = [ faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpun";
    rev = "cebf3ac6d3e4d90944befe14f90ceafb1829717b";
    hash = "sha256-LcvKXMn66NYTB64IYznvY8Da8zkiJqE+0GVp5fQCjow=";
  };
}
