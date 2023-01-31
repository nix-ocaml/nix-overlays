{ fetchFromGitHub, buildDunePackage, menhir, menhirLib, ocaml }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange-compiler-libs";
    rev = "12e89a7";
    sha256 = "sha256-OYFYFfgvYAxOYGzh2/aebaGMdgPRfiCz+HWw8aUgi/A=";
  };
  propagatedBuildInputs = [ menhir menhirLib ];
}
