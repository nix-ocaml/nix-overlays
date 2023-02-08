{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "8e1dfc4";
    sha256 = "sha256-+ysLBJQp6tDYbyxB+NeVssMFHACvuHg2wOFRq7pXKjE=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
