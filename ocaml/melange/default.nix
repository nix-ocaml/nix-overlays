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
    rev = "65d1702e21fed1a700e8eafdfcafa54d85758115";
    hash = "sha256-8Mn38JGK32TkiApc6pwbQO25/Uy7T1D5iT6rV8wrkLI=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 ];
  nativeBuildInputs = [ cppo menhir makeWrapper ];
  propagatedBuildInputs = [ cmdliner dune-build-info ppxlib menhirLib ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
  '';

  meta.mainProgram = "melc";
}
