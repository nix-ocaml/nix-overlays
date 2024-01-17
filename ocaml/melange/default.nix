{ base64
, buildDunePackage
, cppo
, cmdliner
, dune-build-info
, fetchFromGitHub
, jq
, lib
, makeWrapper
, menhir
, menhirLib
, merlin
, nodejs_latest
, ocaml
, ounit2
, ppxlib
, reason
, tree
}:

buildDunePackage {
  pname = "melange";
  version = "2.1.0";
  duneVersion = "3";

  src =
    if (lib.versionOlder "5.1" ocaml.version) then
      fetchFromGitHub
        {
          owner = "melange-re";
          repo = "melange";
          rev = "d2715c469e8cf8bf8cff81b897c212094a9517c5";
          hash = "sha256-Z1l6wyaB9pqQhulSBULh8PJ4+dOaX5SDh1SB8BAc7SM=";
          fetchSubmodules = true;
        }
    else
    # https://github.com/melange-re/melange/tree/v3-414
      fetchFromGitHub
        {
          owner = "melange-re";
          repo = "melange";
          rev = "794842d87f5fce7121eb8b2add65e91392c69fe3";
          hash = "sha256-s7Lo7cYZA0BYJcNH1f2sUOxgr/eEo/Vl3U+zn6FK6/Y=";
          fetchSubmodules = true;
        };

  doCheck = lib.versionOlder "5.1" ocaml.version;

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
