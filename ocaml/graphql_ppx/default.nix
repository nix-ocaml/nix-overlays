{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/48e7a45b399e8c2fddc950f4fc52da6a9a3c21fc.tar.gz;
    sha256 = "0wxkp9ywmxhhs29rljn9lzlacqjqxgiacvvp4w1147zagmids066";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
