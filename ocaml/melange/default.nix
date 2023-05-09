{ fetchFromGitHub
, buildDunePackage
, dune-build-info
, cppo
, cmdliner
, melange-compiler-libs
, base64
, makeWrapper
, ppxlib
}:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "e379b5304cf18cfae52fff929c278ff92cb54e9e";
    hash = "sha256-T3vN2Ewlh4X1T3kKwRW+cZvob+FaE9WUWCEbUcn56KQ=";
  };

  nativeBuildInputs = [ cppo ];
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [
    cmdliner
    melange-compiler-libs
    base64
    dune-build-info
    ppxlib
  ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
  '';

  meta.mainProgram = "melc";
}
