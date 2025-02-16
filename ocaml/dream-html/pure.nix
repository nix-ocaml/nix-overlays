{ lib, buildDunePackage, fetchFromGitHub, uri }:

buildDunePackage {
  pname = "pure-html";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "yawaramin";
    repo = "dream-html";
    rev = "v3.10.0";
    sha256 = "sha256-OlO3g+cEP27GjxJZT0jCTRkICLFRLS0jWkitqXeAVX8=";
  };

  propagatedBuildInputs = [ uri ];

  meta = {
    description =
      "Write HTML directly in your OCaml source files with editor support.";
    license = lib.licenses.gpl3;
  };
}
