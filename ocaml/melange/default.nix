{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/d1ca4fc34ba477eb1332e1684266cbdd3a75aee9.tar.gz;
    sha256 = "195n3hh447yk3msf4ja7a4h98f9cg26kf3pkbrzsxvddsn9ffyzi";
  };

  nativeBuildInputs = [
    gnutar
    dune
    ocaml
    findlib
    cppo
  ];

  propagatedBuildInputs = [
    cmdliner
    dune-action-plugin
    melange-compiler-libs
    reason
  ];

  dontConfigure = true;

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
