{ stdenv
, opaline
, buildDunePackage
, cppo
, cmdliner
, dune-action-plugin
, melange-compiler-libs
, reason
}:

buildDunePackage rec {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/a175fc0.tar.gz;
    sha256 = "0xgx08r19kfif8qly2sylg5ihfncllm6ghjxsjnyijs2jcannzpf";
  };

  nativeBuildInputs = [ cppo ];

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
