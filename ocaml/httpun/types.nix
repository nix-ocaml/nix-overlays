{ fetchFromGitHub, buildDunePackage, faraday }:

buildDunePackage {
  version = "0.1.0-dev";
  pname = "httpun-types";
  propagatedBuildInputs = [ faraday ];

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpun/releases/download/0.1.0/httpun-0.1.0.tbz;
    sha256 = "1lclla34qc03yss3vfbw83nmxg3r9ccik6013vn8vkz189glc1sh";
  };
}
