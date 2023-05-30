{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "5910d1c0ab4483f1abe3cc463dfcccf906ba9a90";
    hash = "sha256-1kK3J8Z0lBQxLg7D1xfgo/5Zh5OjB0MBsBYDcOnvp/0=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
