{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.0-beta.21";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/3171348a6b22cb217b20393ec23ae783b8604281.tar.gz;
    sha256 = "1sf721ygr5r64gfj4kf9sfak7d0929msl2dv2lv4lvjylhlvwwr2";
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
