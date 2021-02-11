{ bzip2, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "dose3";
  version = "6.1";
  src = builtins.fetchurl {
    url = https://gitlab.com/irill/dose3/-/archive/6.1/dose3-6.1.tar.gz;
    sha256 = "0cqdk3gdf4sxyv073s3xmgcp78n03la7mpahvn41hw339z3kcjgb";
  };

  propagatedBuildInputs = [
    bzip2
    ocaml_extlib
    base64
    camlbz2
    camlzip
    cudf
    ocamlgraph
    re
    parmap
    stdlib-shims
  ];
}
