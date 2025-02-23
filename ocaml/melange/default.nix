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
  version = "5.0.1";
  duneVersion = "3";

  src =
    if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.1-53/melange-5.0.1-53.tbz";
          sha256 = "1v4gvbs4sg9w0q00i7laq73zfsl184a42qhzqk3v1723wl0nxcmb";
        }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.1-52/melange-5.0.1-52.tbz";
          sha256 = "04xnp651y13rn4chcsawnpyks3fp6wirrsl62mdhmiggv94a4qk6";
        }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl
        {
          url = "https://github.com/melange-re/melange/releases/download/5.0.1-51/melange-5.0.1-51.tbz";
          sha256 = "0vpw28qn8rvpb06dcgxgq7z0s8y7lxmwjwgc2336mp7jfindllvp";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/melange-re/melange/releases/download/5.0.1-414/melange-5.0.1-414.tbz";
        sha256 = "10n2ds6b9ajq7ccazp0sffx9jnxlazlbkd38vyz0s2zg0la72vgh";
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
