{ buildDunePackage
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
, stdenv
}:

buildDunePackage {
  pname = "melange";
  version = "5.0.0";
  duneVersion = "3";

  src =
    if (lib.versionOlder "5.3" ocaml.version) then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.0-53/melange-5.0.0-53.tbz";
          sha256 = "1c2xmc471z5s97sbrvxibryl9qw8m1m922bw8gw0w9a4v16zz7b5";
        }
    else if (lib.versionOlder "5.2" ocaml.version) then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.0-52/melange-5.0.0-52.tbz";
          sha256 = "0r712vh5kf6cxkajn47j7zx58r9jrh8z6r7a2ngpn277rf4c2a0g";
        }
    else if (lib.versionOlder "5.1" ocaml.version) then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.0-51/melange-5.0.0-51.tbz";
          sha256 = "181c2rkwindn6mnqm1p8a1x7rhf2kz0q81v9g1hqw3n4mjk3mxdc";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/5.0.0-414/melange-5.0.0-414.tbz";
        sha256 = "1fpskdmgrhcfqqkirg56h9592ynqnri1fmcgywcdbrcv3q9svgyk";
      };

  doCheck = false;

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
