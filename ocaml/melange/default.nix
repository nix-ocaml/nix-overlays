{ buildDunePackage
, cppo
, cmdliner
, dune-build-info
, fetchFromGitHub
, jq
, lib
, fetchpatch
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
  version = "5.1.0";
  duneVersion = "3";

  src =
    if lib.versionOlder "5.4" ocaml.version then
      fetchFromGitHub
        {
          owner = "melange-re";
          repo = "melange";
          rev = "abe0ba63ad35ffe2a2bb96a02e67fbad85e895c7";
          fetchSubmodules = true;
          hash = "sha256-QF4lAAWh+PMS8eVkGNM/jYXywO6c7dLJbI4oPaDSeHY=";
        }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.1.0-53/melange-5.1.0-53.tbz";
          sha256 = "1ad4bh1jvdn2cjsp9v6zr9br999qbgdlq5p2ff1zzzm57c7w7app";
        }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.1.0-52/melange-5.1.0-52.tbz";
          sha256 = "1zfyd9ax55dcv6idqmvyw3h2cf8p76y9hf11cc1r1p58c2f0hqhh";
        }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.1.0-51/melange-5.1.0-51.tbz";
          sha256 = "14mhw78gwzv8ncicl35i48gs6fpbsdgrfvbfx9gw2an4jaypr08c";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/5.0.1-414/melange-5.0.1-414.tbz";
        sha256 = "10n2ds6b9ajq7ccazp0sffx9jnxlazlbkd38vyz0s2zg0la72vgh";
      };

  patches =
    lib.optional
      ((lib.versionAtLeast ppxlib.version "0.36") && !(lib.versionAtLeast ocaml.version "5.4"))
      (fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/melange-re/melange/pull/1352.patch";
        hash = "sha256-PMf66nB743nzW4/xblHjNZFv1BS8xC9maD+eCDDUWAY=";
        excludes = [
          "*.opam"
          "*.template"
        ];
      });

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
