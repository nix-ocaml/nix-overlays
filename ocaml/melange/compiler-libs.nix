{ fetchFromGitHub, buildDunePackage, menhir, menhirLib, ocaml }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange-compiler-libs";
    rev = "575ac4c24b296ea897821f9aaee1146ff258c704";
    hash = "sha256-icjQmfRUpo2nexX4XseQLPMhyffIxCftd0LHFW+LOwM=";
  };
  nativeBuildInputs = [ menhir ];
  propagatedBuildInputs = [ menhirLib ];
}
