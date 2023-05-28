{ fetchFromGitHub
, buildDunePackage
, dune-build-info
, cppo
, cmdliner
, base64
, makeWrapper
, menhir
, menhirLib
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
    # https://github.com/melange-re/melange/pull/583
    rev = "47c95b328039161142c6313843100ffb989282f5";
    hash = "sha256-bAlcd7cOFvhspb6mWHar1qZfS2/NmKVk0VJKqAx3EO4=";
    fetchSubmodules = true;
  };

  # https://github.com/melange-re/melange/pull/544
  patches = [ ./new-reactjs-jsx-ppx.patch ];

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 reactjs-jsx-ppx ];
  nativeBuildInputs = [ cppo menhir makeWrapper ];
  propagatedBuildInputs = [
    cmdliner
    base64
    dune-build-info
    ppxlib
    menhirLib
  ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB \
      "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
  '';

  meta.mainProgram = "melc";
}
