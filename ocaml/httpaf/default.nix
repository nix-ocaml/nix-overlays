{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/b78a84204fb10f48f9e38f3acec6ff9c759e0963.tar.gz;
    sha256 = "1x72xlamxaqrkplzn0wfd6hzkc7cc11inqwn03zp541qkrjfh0g2";
  };
}
