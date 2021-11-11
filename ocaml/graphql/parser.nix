{ buildDunePackage, alcotest, menhir, fmt, re }:

buildDunePackage {
  pname = "graphql_parser";
  version = "0.13.0-dev";
  src = builtins.fetchurl
    {
      url = https://github.com/anmonteiro/ocaml-graphql-server/archive/5354276b91f7b58a04f6de471528bede00d97478.tar.gz;
      sha256 = "0f4ji4lszqkgkgw4k9acbyk3v5yk697h5gvpfv1nd2cw9vac6d4r";
    };
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ menhir fmt re ];
}
