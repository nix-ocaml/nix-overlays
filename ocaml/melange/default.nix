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
, nodejs_latest
, tree
}:

buildDunePackage {
  pname = "melange";
  version = "2.0.0-dev";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "64b68c074039fb7f168b01bfc568abba352bceb4";
    hash = "sha256-mOlUVzZqpVo9q9O1e6OLVa0e+JuaKc1WjuA9eFiMG2c=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 ];
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
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange:$OCAMLFIND_DESTDIR/melange/belt/melange:$OCAMLFIND_DESTDIR/melange/dom/melange"
  '';


  meta.mainProgram = "melc";
}
