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
    url = https://github.com/mirage/conan/releases/download/v0.0.2/conan-cli-0.0.2.tbz;
    sha256 = "11d35nrapldwbr1qmxj50y560jhp3qyyh9iaxkcqhq0r4im4r5r7";
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
