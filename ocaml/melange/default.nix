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
    rev = "3becb7c2735135fb5177bca4274320874acd1a18";
    hash = "sha256-C+EDnO8enx6fLwMPWIDiuJ6u8XtS9cMDwWctyCmCzbM=";
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
