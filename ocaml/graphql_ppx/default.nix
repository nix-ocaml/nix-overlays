{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.0-beta.22";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/v1.0.0-beta.22.tar.gz;
    sha256 = "1597gvksdcz725b0l0n2wnhnjjmw70qbkir3mdfrf153v5xkg7fx";
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
