{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "d51ad5e45769e4a347806cdba3cf08da8a791248";
    hash = "sha256-u7aMjIBYhfKf09BpVrH/Lco+YI5IWjnlmMKGKk1JR28=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
