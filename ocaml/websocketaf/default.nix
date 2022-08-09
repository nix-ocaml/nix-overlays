{ buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "0.0.1-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/defd6413ff.tar.gz;
    sha256 = "0qizsi9f0z0cfiymjpflc3dz4rhn8idxqib7mpx2cp8dfkyf4vcj";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
