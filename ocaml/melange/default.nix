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
  version = "7.0.1";
  src =
    if lib.versionAtLeast ocaml.version "5.5" then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-55/melange-7.0.1-55.tbz";
        sha256 = "1yvs183qgywcpm5x8sq36pg066hc4wzi780nvvmjh9d81n3c0xw3";
      }
    else if lib.versionOlder "5.4" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-54/melange-7.0.1-54.tbz";
        sha256 = "0cvzvsllfk335jgihpkbpxgnpls6q905lxg6mdc7y38ds4yrvgs9";
      }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-53/melange-7.0.1-53.tbz";
        sha256 = "0l2iy06rqnqqnpk9i44v62ina8hk0h8nyhdnwwmq6rwl4r9p85r5";
      }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-52/melange-7.0.1-52.tbz";
        sha256 = "08p8gqhwgqyqzhf3kmpkzzp5ns5aqz1mrljdb81dibg8ysva1n83";
      }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-51/melange-7.0.1-51.tbz";
        sha256 = "1cl3mnc01a12vhmsbs62gm9zzzz3bjahr57rfis30s6i7iialic5";
      }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/7.0.1-414/melange-7.0.1-414.tbz";
        sha256 = "19x8fkl4wxlh58w1ciy13l4zxqrzw446wfyib7xnh440p5fqigac";
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
