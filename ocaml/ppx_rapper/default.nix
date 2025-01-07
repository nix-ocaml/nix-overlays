{ fetchFromGitHub, buildDunePackage, base, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "5b0e62def2d5cc6cbe3dedec1ecb289bee350f9a";
    hash = "sha256-Fn13E8H5+ciEIF5wIA6qzEGX5GLe0SYz7i/TSdk1g1M=";
  };

  propagatedBuildInputs = [ caqti pg_query base ];
}
