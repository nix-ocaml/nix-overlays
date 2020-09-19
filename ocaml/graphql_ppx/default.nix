{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.1";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/v1.0.1.tar.gz;
    sha256 = "0ljyf3xgavs4szvz349zd0f4wdwvs6z6h94kxzivm0dbpkp4qqxv";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    yojson
    ocaml-migrate-parsetree
    ppx_tools_versioned
    reason
    menhir
  ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
