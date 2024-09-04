{ fetchFromGitHub, buildDunePackage, faraday }:

buildDunePackage {
  version = "0.2.0";
  pname = "httpun-types";
  propagatedBuildInputs = [ faraday ];

  src = builtins.fetchurl {
    url = "https://github.com/anmonteiro/httpun/releases/download/0.2.0/httpun-0.2.0.tbz";
    sha256 = "0b5xhyv7sbwls8fnln1lp48v5mlkx3ay7l8820f8xbl59kpjgkm2";
  };
}
