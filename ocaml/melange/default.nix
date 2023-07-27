{ fetchFromGitHub
, buildDunePackage
, dune-build-info
, cppo
, cmdliner
, base64
, makeWrapper
, menhir
, menhirLib
, ppxlib
, ounit2
, reason
, nodejs_latest
, tree
}:

buildDunePackage {
  pname = "melange";
  version = "2.0.0-dev";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "d40ada31cc0959d21f47ad9bea33814804762171";
    hash = "sha256-tpXNXI1XFEWplFi6C/tLPMxvZYfqeBtiNTdNGJVHLKA=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeCheckInputs = [ nodejs_latest reason tree ];
  checkInputs = [ ounit2 ];
  nativeBuildInputs = [ cppo menhir makeWrapper ];
  propagatedBuildInputs = [
    cmdliner
    base64
    dune-build-info
    ppxlib
    menhirLib
  ];

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange:$OCAMLFIND_DESTDIR/melange/belt/melange:$OCAMLFIND_DESTDIR/melange/dom/melange"
  '';


  meta.mainProgram = "melc";
}
