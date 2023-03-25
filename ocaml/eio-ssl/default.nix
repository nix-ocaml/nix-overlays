{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/releases/download/0.1.1/eio-ssl-0.1.1.tbz;
    sha256 = "1v24k03ml0hyycxx87z0nyf9qqa447la9kycm7hvhrs68zsn2d6b";
  };
  propagatedBuildInputs = [ ssl eio ];
}
