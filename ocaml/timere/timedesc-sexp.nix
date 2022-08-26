{ buildDunePackage
, timedesc
, timedesc-tzlocal
, sexplib
}:

buildDunePackage {
  pname = "timedesc-sexp";
  inherit (timedesc-tzlocal) src version;
  propagatedBuildInputs = [ timedesc sexplib ];
}
