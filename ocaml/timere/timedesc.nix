{ buildDunePackage
, timedesc-tzdb
, timedesc-tzlocal
, seq
, angstrom
, ptime
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
