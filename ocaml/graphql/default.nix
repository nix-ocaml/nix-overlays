{ ocamlPackages }:

with ocamlPackages;
let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/72f597621fb1b32c70dd8cda7aeb55768715598b.tar.gz;
      sha256 = "05fn8v6z3n50d3pjqpbc4744cds2famjb1cjxky55zldyzrss28b";
    };
  } // args);

in
{
  graphql_parser = buildGraphql {
    pname = "graphql_parser";
    checkInputs = [ alcotest ];
    propagatedBuildInputs = [ menhir fmt re ];
  };

  graphql = buildGraphql {
    pname = "graphql";
    checkInputs = [ alcotest ];
    propagatedBuildInputs = [ graphql_parser yojson rresult seq ];
  };

  graphql-lwt = buildGraphql {
    pname = "graphql-lwt";
    checkInputs = [ alcotest ];
    propagatedBuildInputs = [ graphql lwt ];
  };
}
