{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "dune-release";
  version = "1.3.3";
  useDune2 = true;
  src = builtins.fetchurl {
    url = https://github.com/ocamllabs/dune-release/releases/download/1.3.3/dune-release-1.3.3.tbz;
    sha256 = "04qmgvjh1233ri878wi5kifdd1070w5pbfkd8yk3nnqnslz35zlb";
  };

  propagatedBuildInputs = [
    fmt
    bos
    cmdliner
    re
    opam-format
    opam-state
    opam-core
    rresult
    logs
    odoc
  ];
}
