{ buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/468d618.tar.gz;
    sha256 = "0b3ms17844mzxyrffgvmj73rvlj97zjj7gi1qdijz96ha76fgzx8";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
