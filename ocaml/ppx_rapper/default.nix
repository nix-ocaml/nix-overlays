{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "03fd3d47b4fd143766c07e4a4a696a057945f8da";
    hash = "sha256-RxZeknsuQrW4OEW8b0JD/K/Jex6K6C9/q1w2FlpDw7g=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
