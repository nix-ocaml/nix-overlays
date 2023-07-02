{ lib, fetchFromGitHub, buildDunePackage, ezjsonm, fmt, logs, cmdliner, ppxlib }:

buildDunePackage {
  pname = "matrix-common";
  version = "2023-07-02";
  src = fetchFromGitHub {
    repo = "ocaml-matrix";
    owner = "mirage";
    rev = "d77c5bbde67028d444551cd28c05cb44cd381265";
    sha256 = "sha256-i7iqtI/GFFLFIgj+bKZ5n0RrmF1RVRzolq9eVulUNeY=";
  };

  propagatedBuildInputs = [
    ezjsonm
    fmt
    logs
    cmdliner
    ppxlib
  ];

  doCheck = true;
}
