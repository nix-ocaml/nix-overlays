{
  buildDunePackage,
  cppo,
  cmdliner,
  dune-build-info,
  fetchFromGitHub,
  jq,
  lib,
  makeWrapper,
  menhir,
  menhirLib,
  merlin,
  nodejs_latest,
  ocaml,
  ounit2,
  ppxlib,
  reason,
  tree,
  stdenv,
}:

buildDunePackage {
  pname = "melange";
  version = "4.0.0";
  duneVersion = "3";

  src =
    if (lib.versionOlder "5.2" ocaml.version) then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/4.0.1-52/melange-4.0.1-52.tbz";
        sha256 = "0dvmdxzkvr5qc064p9q8yciv5jkcw9njn1nxhzrpwb9dlj344jci";
      }
    else if (lib.versionOlder "5.1" ocaml.version) then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/4.0.0-51/melange-4.0.0-51.tbz";
        sha256 = "1mdxqqw3jyaf3ig1w9als2mghf9axbln6mm5k1x76pjrkp71i3gp";
      }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/4.0.0-414/melange-4.0.0-414.tbz";
        sha256 = "14rcq4qxwc33xlnpfxjqz9fs5l29jvzc04jvpzgvpj08fqww70iw";
      };

  doCheck = false;

  nativeCheckInputs = [
    nodejs_latest
    reason
    tree
    merlin
    jq
  ];
  checkInputs = [ ounit2 ];
  nativeBuildInputs = [
    cppo
    menhir
    makeWrapper
  ];
  propagatedBuildInputs = [
    cmdliner
    dune-build-info
    ppxlib
    menhirLib
  ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange"
  '';

  meta.mainProgram = "melc";
}
