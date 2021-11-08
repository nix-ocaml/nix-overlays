{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/a11ceb1.tar.gz;
    sha256 = "0njivayll8hl56ys93z4q14l563ksiv1j6m7kkfbrlgx0dz6lxhx";
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

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/melange
    cd $out/lib/melange

    tar xvf $OCAMLFIND_DESTDIR/melange/libocaml.tar.gz
    mv others/* .
    mv runtime/* .
    mv stdlib-412/stdlib_modules/* .
    mv stdlib-412/* .
    rm -rf others runtime stdlib-412

    runHook postInstall
  '';
}
