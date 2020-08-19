{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;

let
  bin_folder = if stdenv.isDarwin then "darwin" else "linux";
in
stdenv.mkDerivation rec {
  name = "bucklescript";
  version = "8.2.0-dune";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "bucklescript";
    rev = "8ce15cce9242fcb7e297ea5458569c88810df579";
    sha256 = "1vayld0alff6hnb921j4b8z3634k5qxpp5v7zc5kwjpif6p03xmh";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gnutar
    nodejs
    dune_2
    ocaml
    findlib
    cppo
  ];

  propagatedBuildInputs = [
    reason
    camlp4
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    dune build -p ${name} --display=short
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/ocaml
    tar -C $out/lib/ocaml -xzf $out/share/bucklescript/libocaml.tar.gz --strip-components=1

    runHook postInstall
  '';
}

