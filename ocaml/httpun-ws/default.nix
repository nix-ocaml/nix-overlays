{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "httpun-ws";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpun-ws/releases/download/0.1.0/httpun-ws-0.1.0.tbz;
    sha256 = "1p0z8sbzsm42ifl3awc923zz24f559lz5w3vn200wr0f0imcl6cx";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
