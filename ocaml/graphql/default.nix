{ ocamlPackages }:

with ocamlPackages;
let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/716485a61fe0824250aed87e80c0dadf9937bd29.tar.gz;
      sha256 = "1gsw5nc1q3cganifkmq1qf7x1vp3bimisllka8ygxmqbn6zqki12";
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
