{ lib, fetchFromGitHub, buildDunePackage, matrix-common, ezjsonm, fmt, logs, ppxlib }:

buildDunePackage {
  pname = "matrix-ctos";
  inherit (matrix-common) version src doCheck;

  propagatedBuildInputs = [
    matrix-common
    ezjsonm
    fmt
    logs
    ppxlib
  ];
}
