{ fetchFromGitHub, buildDunePackage, ppx_optcomp, ocaml-migrate-types }:

buildDunePackage {
  pname = "typedppxlib";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "EduardoRFS";
    repo = "typedppxlib";
    rev = "658d0b1";
    sha256 = "sha256-Cocy+xxeRaEztptMkxEUqwFwoMgGjm3Zti6IBXd/V7U=";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-types ];
}
