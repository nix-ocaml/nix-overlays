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
  version = "3.0.0";
  duneVersion = "3";

  src =
    if (lib.versionOlder "5.1" ocaml.version) then
      (builtins.fetchurl {
        url = https://github.com/melange-re/melange/releases/download/3.0.0-v51/melange-3.0.0-v51.tbz;
        sha256 = "1apismbgyq8m8kl1hh43wcb6ffp4hmz2ly53qdwfpmj1rb03cnp6";
      })
    else
      builtins.fetchurl {
        url = https://github.com/melange-re/melange/releases/download/3.0.0-v414/melange-3.0.0-v414.tbz;
        sha256 = "122vxyprcfpgymz8w815z8kqaa9q1warfhzm70j5bs8v7r9jj7wl";
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
