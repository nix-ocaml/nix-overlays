{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "0d34b1109c40eefb2b7c378d874f8d3489794901";
    hash = "sha256-u7aMjIBYhfKf09BpVrH/Lco+YI5IWjnlmMKGKk1JR28=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
