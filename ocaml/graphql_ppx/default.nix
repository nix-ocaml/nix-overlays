{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/77a8f47eff4c6ec322c5101fcf0621c1b2d24960.tar.gz;
    sha256 = "0sb2z7cbsir8sgp5cckh2kr3vhps6wp2g5v8h25sww56yvp37k0s";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
