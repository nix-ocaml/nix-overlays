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
, mirage-types
, mirage-types-lwt
, mirage-runtime
, re
, uutf
, ptime
}:

buildDunePackage {
  pname = "conan";
  version = "0.0.1";
  src = builtins.fetchurl {
    url = https://github.com/mirage/conan/releases/download/v0.0.1/conan-cli-v0.0.1.tbz;
    sha256 = "1xrg238bzqj0gk2i49va9nqzq7yl917awpi41nwkc1lq7k98alb2";
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
    mirage-types
    mirage-types-lwt
    mirage-runtime
  ];
}
