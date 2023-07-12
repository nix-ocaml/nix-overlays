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
    url = https://github.com/mirage/conan/releases/download/v0.0.4/conan-0.0.4.tbz;
    sha256 = "174c0zv823sqc3ng43x35zrgwgxsm6nb33c2hddnnibnkpljxrj1";
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
