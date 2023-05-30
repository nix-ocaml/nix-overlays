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
    rev = "4e993cef346020ab2e4f3d346a4d99a5219e4fda";
    hash = "sha256-pvUs3LJWSNT3HeGhjJ61DbZNU4zN8WQB9QdEkgaKHBU=";
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
