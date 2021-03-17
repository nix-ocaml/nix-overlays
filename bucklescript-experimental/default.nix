{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;
let
  bin_folder = if stdenv.isDarwin then "darwin" else "linux";
in
stdenv.mkDerivation rec {
  name = "bucklescript";
  version = "9.0.0-dune";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "bucklescript";
    rev = "5dcb618f4e3cf215c0207837ee7277d1531398ff";
    sha256 = "0h92r392s90bg2h91j3v34ndbl9kgar6j1xvbdm7129my02nf1f6";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gnutar
    dune
    ocaml
    findlib
    cppo
  ];

  propagatedBuildInputs = [ reason dune-action-plugin ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    dune build -p ${name}
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
