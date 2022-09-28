{ buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/2d4aa8d.tar.gz;
    sha256 = "0sk83pwf271g1w5ivnn0z2kaq744w02gka41s5ggazxnfzd1qh2w";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
