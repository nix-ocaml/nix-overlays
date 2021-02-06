{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/056dc58ac111b503d4f358238f11c52f5a801031.tar.gz;
    sha256 = "0l0fyhhhifxkgyqlqa7j1bpsk0c3cngk9di53s2r054iylrc2g9b";
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
