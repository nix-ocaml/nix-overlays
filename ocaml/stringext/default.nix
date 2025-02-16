{ lib, buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "stringext";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "rgrinberg";
    repo = "stringext";
    rev = "1.6.0";
    sha256 = "sha256-HacuesAITPZdT/Sd7XX3jj2vMRhnOWBqe2PmPWxlCdQ=";
  };

  meta = {
    description =
      "Extra string functions for OCaml";
    license = lib.licenses.mit;
  };
}
