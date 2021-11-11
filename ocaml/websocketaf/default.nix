{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "websocketaf";
  version = "0.0.1-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/248a2cb.tar.gz;
    sha256 = "1zpbfsh15933pcjam6pxg9fx710hypi2l6p1rgccrvjjkin96yyi";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
