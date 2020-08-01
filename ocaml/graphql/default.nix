{ ocamlPackages }:

with ocamlPackages;

let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/cab25bba231ac9debd19e2dddc7fd63c8cedfed2.tar.gz;
      sha256 = "0inmc2r09rx9070bpnrrdllnncp1fcjhl765hy8pzz9zw36clyq5";
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
