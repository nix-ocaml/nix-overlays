{ buildDunePackage
, alcotest
, crowbar
, fmt
, rresult
, mirage
, mirage-unix
, mirage-bootvar-unix
, mirage-console-unix
, mirage-clock-unix
, mirage-logs
, mirage-runtime
, re
, uutf
, ptime
}:

buildDunePackage {
  pname = "conan";
  version = "0.0.1";
  src = builtins.fetchurl {
    url = https://github.com/mirage/conan/releases/download/v0.0.5/conan-0.0.5.tbz;
    sha256 = "13zvay99i8pbzi2d1c24ppd9z9szj6nhdy7g6n8bx9zgl6k9rbh4";
  };

  doCheck = false;
  propagatedBuildInputs = [ re uutf ptime ];
  checkInputs = [
    alcotest
    crowbar
    fmt
    rresult
    mirage
    mirage-unix
    mirage-bootvar-unix
    mirage-console-unix
    mirage-clock-unix
    mirage-logs
    mirage-runtime
  ];
}
