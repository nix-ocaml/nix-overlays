{
  buildDunePackage,
  timedesc,
  sexplib,
}:

buildDunePackage {
  pname = "timedesc-sexp";
  inherit (timedesc) src version sourceRoot;
  propagatedBuildInputs = [
    timedesc
    sexplib
  ];
}
