{ buildDunePackage
, timedesc-tzdb
, timedesc-tzlocal
, seq
, angstrom
, ptime
, result
, crowbar
, alcotest
, qcheck-alcotest
, qcheck
}:

buildDunePackage {
  pname = "timedesc";
  inherit (timedesc-tzlocal) src version;
  propagatedBuildInputs = [
    timedesc-tzdb
    timedesc-tzlocal
    seq
    angstrom
    ptime
    result
  ];

  doCheck = true;
  checkPhase = ''
    dune runtest -p timedesc timedesc-sexp
  '';
  checkInputs = [
    crowbar
    alcotest
    qcheck-alcotest
    qcheck
  ];
}
