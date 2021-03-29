{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/refs/tags/v1.1.0.tar.gz;
    sha256 = "0rqwra6gv1135rfsp2r5cvribzgjakxkp3r0gqgjky55i86zn0q0";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
