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
}:

buildDunePackage {
  pname = "melange";
  version = "7.0.0";
  src =
    if lib.versionAtLeast ocaml.version "5.5" then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-55/melange-7.0.0-55.tbz";
        sha256 = "0mnz7hwdgpz3x4vvad7ava7ldm0n5ph467z0xw30a8wwb482j7gp";
      }
    else if lib.versionOlder "5.4" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-54/melange-7.0.0-54.tbz";
        sha256 = "0z0s4p0syz3f864bl53h0b986g602nwx408828f0l6lw68mify6b";
      }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-53/melange-7.0.0-53.tbz";
        sha256 = "0r3fpnsj2qc5nrmicb27nw9hlsqp3vkc30rsyjf7vknif2kr8g9b";
      }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-52/melange-7.0.0-52.tbz";
        sha256 = "0zr33qqy9mic4h2w3jmiqf9iwblsl2qvzpspd8v5dr24c9696f2a";
      }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-51/melange-7.0.0-51.tbz";
        sha256 = "040307587j6f47aqh44av22v1xmfcych6l7lm7qfiyfzncdwdcdi";
      }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.0-414/melange-7.0.0-414.tbz";
        sha256 = "0gzl8z6i2688wyy9r0mifcvwkn0xx4k4c5c1dfkykan83wmfld9d";
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
