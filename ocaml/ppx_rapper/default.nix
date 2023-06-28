{ fetchFromGitHub, buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "2222edbbe68db7ba1ab0c7a2688c227ea5c0f230";
    hash = "sha256-HF7VVS2o5tdblkvd3Rwp8dohlwMJ/Dyo0fnd+D1+8vc=";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
