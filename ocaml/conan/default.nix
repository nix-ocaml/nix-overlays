{ buildDunePackage
, alcotest
, crowbar
, fetchFromGitHub
, fmt
, rresult
, mirage
, mirage-unix
, mirage-bootvar-unix
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
  src = fetchFromGitHub {
    owner = "mirage";
    repo = "conan";
    # https://github.com/mirage/conan/pull/34
    rev = "1ac2302cd2be8f40c33831b935e92dc108ef2e34";
    hash = "sha256-1HEqmK/HCvKxW7vv+zn40wT9TlHgEzw0cMJDXSRKTvE=";
  };

  propagatedBuildInputs = [ re uutf ptime ];
}
