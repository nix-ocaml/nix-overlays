{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "88f421cc0399c305764357bf99eb17b9034a096c";
    hash = "sha256-jYX335WESN05r0sb5FUHKri+EyoKbJi3jPEvBRYG82U=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
