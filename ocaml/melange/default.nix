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
    rev = "3e08a98718e433f5c240f6fd1920ba0de88f56cc";
    hash = "sha256-TKDIL8kt3LEo5o1cWOXURr4qmWZvYwOVAqhOF3O6YXI=";
    fetchSubmodules = true;
  };

  # https://github.com/melange-re/melange/pull/544
  patches = [ ./new-reactjs-jsx-ppx.patch ];

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 reactjs-jsx-ppx ];
  nativeBuildInputs = [ cppo menhir ];
  buildInputs = [ makeWrapper ];
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
