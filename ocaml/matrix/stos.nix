{ lib, fetchFromGitHub, buildDunePackage, matrix-common, ezjsonm, fmt, logs, mirage-crypto-ec, x509, ppxlib }:

buildDunePackage {
  pname = "matrix-stos";
  inherit (matrix-common) version src doCheck;

  propagatedBuildInputs = [
    matrix-common
    ezjsonm
    fmt
    logs
    ppxlib
    mirage-crypto-ec
    x509
  ];
}
