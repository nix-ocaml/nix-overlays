{ lib, buildDunePackage, fetchFromGitHub, dream }:

buildDunePackage {
  pname = "dream-html";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "yawaramin";
    repo = "dream-html";
    rev = "a0f269f419160cafd8af15bba93c64065b2dad7b";
    sha256 = "sha256-OfdWal7fYqiT+4vfZZi5x6ItBVCP4rPHb2aO5TO6L88=";
  };

  propagatedBuildInputs = [ dream ];

  meta = {
    description =
      "Write HTML directly in your OCaml source files with editor support.";
    license = lib.licenses.gpl3;
  };
}
