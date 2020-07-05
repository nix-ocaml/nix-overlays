{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-graphql-server";
      rev = "9d3b18afb098b9c546c2eb6574bb45a660431a5e";
      sha256 = "12nqyv119cvzfyhb70b72plgz0lsdvk3628jh2kvp8cx4qbvw3g4";
    };
  } // args);

in rec {
  graphql_parser = buildGraphql {
    pname = "graphql_parser";
    buildInputs = [ alcotest ];
    propagatedBuildInputs = [ menhir fmt re ];
  };

  graphql = buildGraphql {
    pname = "graphql";
    buildInputs = [ alcotest ];
    propagatedBuildInputs = [ graphql_parser yojson rresult seq ];
  };

  graphql-lwt = buildGraphql {
    pname = "graphql-lwt";
    buildInputs = [ alcotest ];
    propagatedBuildInputs = [ graphql lwt ];
  };
}
