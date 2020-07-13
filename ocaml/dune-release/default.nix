{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "dune-release";
  version = "1.4.0";
  useDune2 = true;
  src = builtins.fetchurl {
    url = "https://github.com/ocamllabs/dune-release/releases/download/${version}/dune-release-${version}.tbz";
    sha256 = "1frinv1rsrm30q6jclicsswpshkdwwdgxx7sp6q9w4c2p211n1ln";
  };

  propagatedBuildInputs = [
    fmt
    bos
    curly
    cmdliner
    re
    opam-format
    opam-state
    opam-core
    rresult
    logs
    odoc
    yojson
  ];
}
