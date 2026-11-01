{
  buildDunePackage,
  fetchzip,
  seq,
  oseq,
  containers,
  fmt,
  timedesc,
  timedesc-sexp,
  diet,
}:

buildDunePackage rec {
  pname = "timere";
  version = "0.9.0";
  src = fetchzip {
    url = "https://github.com/daypack-dev/timere/releases/download/timere-${version}/timere-${version}.tar.gz";
    hash = "sha256-e+VORetinyrH2MCVXwFMMDC/GjjgWVl5BtLn2QT9yWo=";
    stripRoot = false;
  };

  propagatedBuildInputs = [
    seq
    oseq
    containers
    fmt
    timedesc
    timedesc-sexp
    diet
  ];
}
