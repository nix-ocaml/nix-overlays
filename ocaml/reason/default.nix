{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "reason";
    rev = "db13e434133b90852e021f9b39caa521936b12b5";
    sha256 = "0hnzxi8dz8n9s31hw1n01fg8dd1fz0n4v42prb40d0a3f3i4add7";
  };

  propagatedBuildInputs = [ menhir fix merlin-extend ocaml-migrate-parsetree ];

  buildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
