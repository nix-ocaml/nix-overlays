{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;
let
  bin_folder = if stdenv.isDarwin then "darwin" else "linux";
in
stdenv.mkDerivation rec {
  name = "melange";
  version = "9.0.0-dune";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/f5cb19b7.tar.gz;
    sha256 = "0qrgc9rdzvkv95vb6d7zsi7dvjp1z7232prrvjcpq9ppkp1xhzb2";
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
    dune build -p ${name} -j16
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/ocaml
    cd $out/lib/ocaml

    tar xvf $OCAMLFIND_DESTDIR/melange/libocaml.tar.gz
    mv others/* .
    mv runtime/* .
    mv stdlib-412/stdlib_modules/* .
    mv stdlib-412/* .
    rm -rf others runtime stdlib-412

    runHook postInstall
  '';
}
