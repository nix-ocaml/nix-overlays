{ buildDunePackage
, seq
, timedesc-tzlocal
, oseq
, containers
, fmt
, timedesc
, timedesc-sexp
, diet
}:

buildDunePackage {
  pname = "timere";
  inherit (timedesc-tzlocal) src version;
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
