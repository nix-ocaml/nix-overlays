{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.0-beta.21";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/f394f010799baa00cf9d7054ded5d2ae5aacec76.tar.gz;
    sha256 = "13njw9ghgb91fq3wchgyc19z8qpxrswi3bxhp10i42dcal79yc7g";
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
