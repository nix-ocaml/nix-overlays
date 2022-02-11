{ buildDunePackage, alcotest, menhir, fmt, re }:

buildDunePackage {
  pname = "graphql_parser";
  version = "0.13.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-graphql-server/archive/8266322ca1c5297bd875acf6ed42f8d14168c7d8.tar.gz;
    sha256 = "1pbyk42ym4j645m7wrqxbjq71mi24n4jk3ss6b8nvhdsl621c1sy";
  };
  nativeBuildInputs = [ menhir ];
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ menhir fmt re ];
}
