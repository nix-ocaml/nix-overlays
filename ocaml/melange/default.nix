{ stdenv
, opaline
, buildDunePackage
, cppo
, cmdliner
, melange-compiler-libs
, reason
, lib
, ocaml
}:

buildDunePackage {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/0ad11f3.tar.gz;
    sha256 = "1mmcrv4n4dh82gqchyzh07dhyywy36z6gswjg851s3n223qhq7j1";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs reason ];

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
    rm -rf others runtime stdlib-412 stdlib_modules

    runHook postInstall
  '';
}
