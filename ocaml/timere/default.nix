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

  postPatch = ''
    substituteInPlace timere/time.ml --replace "OSeq.equal ~eq:" "OSeq.equal "

  '';
}
