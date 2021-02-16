{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/reasonml-community/graphql-ppx/archive/aac98883172d97b8112364f45d9a00af284e67d1.tar.gz;
    sha256 = "0bj79hghh90vywrcs01k1wmgs3nb27gwmw1kmbfj17kzly3wycwn";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
