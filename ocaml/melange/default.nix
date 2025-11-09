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
  version = "6.0.0";
  src =
    if lib.versionOlder "5.4" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/6.0.0-54/melange-6.0.0-54.tbz";
          sha256 = "0fxzd7ikffj39i77dfs2i45hc9wi4rq2f6pplml8hvffgqmlxkzb";
        }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/6.0.0-53/melange-6.0.0-53.tbz";
          sha256 = "0dzn6w1dpqwlc2w36mdlzq3nr7sdi40sgpj0w30i7r1xbnyx1x4c";
        }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/6.0.0-52/melange-6.0.0-52.tbz";
          sha256 = "1hqgi07sar32v8lr4w9lhrh3nyqxdzrgjc4j0gix16shglrmn0vk";
        }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/6.0.0-51/melange-6.0.0-51.tbz";
          sha256 = "05hd5jrw8njkqw6mcwfyxrr9m6r1dgqzargmkpf1l109xirysf87";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/6.0.0-414/melange-6.0.0-414.tbz";
        sha256 = "09iznazd55xdbb3h4aqx6rl1ggh2xrfg392v1x0hzrq2g24gxjn5";
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
