{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-graphql-server";
      rev = "cab25bba231ac9debd19e2dddc7fd63c8cedfed2";
      sha256 = "0386sg10lk6cxig2dk3r692y0pqdrddpxrzclknv1ssfrzs0jzfj";
    };
  } // args);

in {
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
