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
    url = https://github.com/mirage/conan/releases/download/v0.0.3/conan-0.0.3.tbz;
    sha256 = "0mp3v9x8c8av8ykm94m971hmcz9h1mdg3svh57c0hkixy6axwiv2";
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
