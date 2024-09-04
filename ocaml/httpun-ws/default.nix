{ fetchFromGitHub
, buildDunePackage
, angstrom
, faraday
, gluten
, httpun
, base64
}:

buildDunePackage {
  pname = "httpun-ws";
  version = "n/a";
  src = builtins.fetchurl {
    url = "https://github.com/anmonteiro/httpun-ws/releases/download/0.2.0/httpun-ws-0.2.0.tbz";
    sha256 = "1zcpqar4qvqfpx390hrf7d8ch3vgd88vfqnqnsfgrd5m1qpcvq7a";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpun base64 ];
}
