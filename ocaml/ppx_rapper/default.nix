{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "26bae31166e32621285d0c811f46148c0207caff";
    hash = "sha256-mqBC78zGCzfuehgEW0EmzftjxwXkLmGshMI5NhHMx9w=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
