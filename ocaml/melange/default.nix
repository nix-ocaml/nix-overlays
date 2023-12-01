{ base64
, buildDunePackage
, cppo
, cmdliner
, dune-build-info
, fetchFromGitHub
, jq
, makeWrapper
, menhir
, menhirLib
, merlin
, nodejs_latest
, ounit2
, ppxlib
, reason
, tree
}:

buildDunePackage {
  pname = "melange";
  version = "2.1.0";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "e8838216706c2ea3dd22c85487d39ba18a2e7748";
    hash = "sha256-tJ4NpyhtGK2D7CixbVcX4VuVl8G0DoqI/0nKXn1uUwQ=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree merlin jq ];
  checkInputs = [ ounit2 ];
  nativeBuildInputs = [ cppo menhir makeWrapper ];
  propagatedBuildInputs = [ cmdliner dune-build-info ppxlib menhirLib ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange"
  '';

  meta.mainProgram = "melc";
}
