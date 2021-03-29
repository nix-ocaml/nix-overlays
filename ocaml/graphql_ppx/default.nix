{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/refs/tags/v1.1.0.tar.gz;
    sha256 = "1dkkcr5ypphlx96n7h448cwazld9phygvlqr5giqvckqk72qc3pn";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
