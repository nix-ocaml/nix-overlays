{ lib, stdenv, ocamlPackages, static ? false }:

with ocamlPackages;

stdenv.mkDerivation {
  name = "carl";
  version = "0.0.1-dev";
  inherit (piaf) src;

  # remove the piaf directories. we're depending on piaf as a lib
  postPatch = ''
    rm -rf vendor lib lib_test multipart multipart_test
  '';
  buildPhase = ''
    dune build bin/carl.exe --display=short --profile=${if static then "static" else "release"}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv _build/default/bin/carl.exe $out/bin/carl
  '';

  nativeBuildInputs = [
    ocaml dune findlib
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
