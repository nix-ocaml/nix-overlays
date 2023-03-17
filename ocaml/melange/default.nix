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
    rev = "2393b2d61e330f45d383640b1837bb9108567428";
    hash = "sha256-JwRlTPKOZXrqsVgDItVxQ2dIW3wvOetBu6j049CQoxg=";
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
