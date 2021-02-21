{ ocamlPackages }:

with ocamlPackages;
let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/a5dde382fa3233322d511a5fddfbf4b07ba61338.tar.gz;
      sha256 = "03p0zsxi092yxpkgzbcg410q0y112s1bgrm7wh1xawrj61vin6vr";
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
