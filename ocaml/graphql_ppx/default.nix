{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.0-beta.22";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/468fad5c55866006329918fb1c06f9695d0a13bd.tar.gz;
    sha256 = "0d3dnzv9ws2mj85l07mnn2ib3hkr2668y9bwscv6sypi4xgd6f03";
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
