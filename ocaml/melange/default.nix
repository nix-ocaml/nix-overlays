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
  version = "2.1.0";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "2.1.0";
    hash = "sha256-kdguJxSQkGShL4RN9N2K52USy9I4SovjcH/F4NiS/8Y=";
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
