{ fetchFromGitHub
, buildDunePackage
, dune-build-info
, cppo
, cmdliner
, melange-compiler-libs
, base64
, makeWrapper
, ppxlib
, ounit2
, reason
, reactjs-jsx-ppx
, nodejs_latest
, tree
}:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "9d6ff197433fdb6f187f3f5709de753921d843c6";
    hash = "sha256-alE+pPKqd2I2axYEq3AFkaZR2O12WxHQ6DbKYWpC1/E=";
  };

  # https://github.com/melange-re/melange/pull/544
  patches = [ ./new-reactjs-jsx-ppx.patch ];

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 reactjs-jsx-ppx ];
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
      --set MELANGELIB \
      "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
  '';

  meta.mainProgram = "melc";
}
