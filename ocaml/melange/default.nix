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
    rev = "c5bf086511ed4830018e67ca63df86045dbe356d";
    hash = "sha256-axGv65Odh4gaPA+fovezkx2HNs9K2K4uqFSWjGVs+yE=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 ];
  nativeBuildInputs = [ cppo menhir makeWrapper ];
  propagatedBuildInputs = [ cmdliner dune-build-info ppxlib menhirLib ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange"
  '';

  meta.mainProgram = "melc";
}
