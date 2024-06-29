{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/releases/download/0.3.0/eio-ssl-0.3.0.tbz;
    sha256 = "02pjffsbyvsdi43948xqpnr8x65n3z00wnyq5qgj6map1d8s504v";
  };
  propagatedBuildInputs = [ ssl eio ];
}
