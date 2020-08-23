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
    rev = "0f18adb02d95bad03c3a70a98c7fd492f23afe23";
    sha256 = "1fjxdyf8ybhj3cmprwpsdyvlvmifvcz9g3n3qab3lxs1x36ab1jw";
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

