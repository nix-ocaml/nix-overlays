{ fetchFromGitHub
, buildDunePackage
, cppo
, cmdliner
, melange-compiler-libs
, base64
, makeWrapper
}:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "a8f50420a548f8323f8be3d9f66ce71336e314fc";
    hash = "sha256-TIDcOiRaMjUEXPbVCFny2drPtb2xS28LVO7WF7iMFoI=";
  };

  nativeBuildInputs = [ cppo ];
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ cmdliner melange-compiler-libs base64 ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"

    mkdir -p $out/lib/melange
    cp -r $OCAMLFIND_DESTDIR/melange/mel_runtime \
          $out/lib/melange/__MELANGE_RUNTIME__
    cp -r $OCAMLFIND_DESTDIR/melange/mel_runtime \
          $out/lib/melange/mel_runtime
  '';

  meta.mainProgram = "melc";
}
