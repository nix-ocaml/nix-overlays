{ lib, fetchFromGitHub, buildDunePackage, ezjsonm, fmt, logs, cmdliner, ppxlib }:

buildDunePackage {
  pname = "matrix-common";
  version = "2023-07-02";
  src = fetchFromGitHub {
    repo = "ocaml-matrix";
    owner = "ulrikstrid";
    rev = "3d807294692069455316af019384f08a7a2ada87";
    sha256 = "sha256-3HP56hYMrbGrsADmS7/TPRKdVM4lKDMEnwfb4LMaunM=";
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
