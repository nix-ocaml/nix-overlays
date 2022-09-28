{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/d7e75c6.tar.gz;
    sha256 = "0ngkwdkc32s913ja18kg4i224dcnxlqvjlgj8lvn5w9bx0s26f49";
  };
}
