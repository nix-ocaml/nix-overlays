{ stdenv
, opaline
, buildDunePackage
, cppo
, cmdliner
, melange-compiler-libs
, reason
, lib
, luv
, base64
, ocaml
}:

buildDunePackage {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/98ac719.tar.gz;
    sha256 = "0fnyrjii02ak6q0gbp76q6albfbd86pbmjz0ddgzf93fil40fdg6";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs reason luv base64 ];

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
