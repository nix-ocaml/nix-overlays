{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0-dev";

  # src = /Users/anmonteiro/projects/graphql_ppx;
  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/b122c05c9c924f0e6538d0d853df0387a3fa6735.tar.gz;
    sha256 = "1vk9kaiv41v0bq1m1wp5hh0lgi0gjii24g8a14kyyfa3mjidpmmb";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    yojson
    ppxlib
    reason
  ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
