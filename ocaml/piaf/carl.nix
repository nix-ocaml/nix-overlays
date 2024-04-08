{ lib
, stdenv
, overrideSDK
, static ? false
, piaf
, ocaml
, dune
, findlib
, cmdliner
, camlzip
, ezgzip
, fmt
}:

let
  stdenv' = if stdenv.isDarwin then overrideSDK stdenv "11.0" else stdenv;
in

stdenv'.mkDerivation {
  name = "carl";
  version = "0.0.1-dev";
  inherit (piaf) src;

  # remove the piaf directories. we're depending on piaf as a lib
  postPatch = ''
    rm -rf vendor lib lib_test multipart multipart_test stream sendfile
  '';
  buildPhase = ''
    dune build bin/carl.exe --display=short --profile=${if static then "static" else "release"}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv _build/default/bin/carl.exe $out/bin/carl
  '';

  nativeBuildInputs = [
    ocaml
    dune
    findlib
  ];

  buildInputs = [
    piaf
    cmdliner
    fmt
    camlzip
    ezgzip
  ];

  meta = {
    description = "`curl` clone implemented using Piaf.";
    license = lib.licenses.bsd3;
  };
}
