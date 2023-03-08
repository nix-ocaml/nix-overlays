{ fetchFromGitHub, buildDunePackage, menhir, menhirLib, ocaml }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange-compiler-libs";
    rev = "48ff923f2c25136de8ab96678f623f54cdac438c";
    sha256 = "sha256-jPp5jpjT9oD2YzAzEBSaQUBBf7+zUU/A3KDwNVuV32A=";
  };
  nativeBuildInputs = [ menhir ];
  propagatedBuildInputs = [ menhirLib ];
}
