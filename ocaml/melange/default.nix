{
  buildDunePackage,
  cppo,
  cmdliner,
  dune-build-info,
  fetchFromGitHub,
  jq,
  lib,
  fetchpatch,
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
  version = "6.0.1";
  src =
    if lib.versionOlder "5.4" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.1-54/melange-6.0.1-54.tbz";
        sha256 = "0rqn05xp5b0839bx4g9zb8ac2c44y925pgfr87qdwbm5r87m6pkd";
      }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.1-53/melange-6.0.1-53.tbz";
        sha256 = "1fvh7nsmxbg6xq7y28hp42gvxml68zyl283cfcdy0abcq4id2pvv";
      }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.1-52/melange-6.0.1-52.tbz";
        sha256 = "0n75chjkb7v1ihpibqg2xcz04dxnfs1k9nhmg62n54q0p4wk04i0";
      }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.1-51/melange-6.0.1-51.tbz";
        sha256 = "0vj7qzxqwfy5gflk4fvazjg6fxjih5zhzyk6wcmkvy6j0h2xbdp4";
      }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.1-414/melange-6.0.1-414.tbz";
        sha256 = "1dcz8f5nlnxyagkcqhi90kkza987ywq82khgxr1xqh27hq8y1k61";
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
