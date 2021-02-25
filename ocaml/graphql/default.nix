{ ocamlPackages }:

with ocamlPackages;
let
  buildGraphql = args: buildDunePackage ({
    version = "0.13.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/5354276b91f7b58a04f6de471528bede00d97478.tar.gz;
      sha256 = "0f4ji4lszqkgkgw4k9acbyk3v5yk697h5gvpfv1nd2cw9vac6d4r";
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
