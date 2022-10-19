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

buildDunePackage rec {
  pname = "melange";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/066c5ebc2.tar.gz;
    sha256 = "0kglmvkb2hmg5s30nzh611p20qgsj03v3clc5f36r4kr2w33m05c";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    cmdliner
    melange-compiler-libs
    reason
    luv
    base64
  ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out --libdir $out/lib ${pname}

    cp package.json bsconfig.json $out

    mv $out/lib/melange/js $out/lib/js
    mv $out/lib/melange/es6 $out/lib/es6
    mv $out/lib/melange/melange/* $out/lib/melange
    rm -rf $out/lib/melange/melange

    runHook postInstall
  '';
}
