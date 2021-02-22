{ ocamlPackages }:

with ocamlPackages;
let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/8b02ca35845adc38e49ffaa23ada1ba2e5a94b1b.tar.gz;
      sha256 = "01awzry2ygs7w56dcv1jx02hhrdx0nh6l061nhd8j56jhi2lc3vj";
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
