{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = fetchFromGitHub {
      owner = "andreas";
      repo = "ocaml-graphql-server";
      rev = "940e86f9ff1a017be2ff64b3a35c71804d9a4729";
      sha256 = "0syd7vwpsxfdfypzdqcmif2hlgi78qadqr4vrvf0zal4m03qz646";
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
    propagatedBuildInputs = [ graphql lwt4 ];
  };
}
