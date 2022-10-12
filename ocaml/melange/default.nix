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
    url = https://github.com/melange-re/melange/archive/d979086.tar.gz;
    sha256 = "0pag3513qkpnm4wadd3dqk7xisv5z7s8hc1cx9vyxxjgbxcnr7kc";
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
