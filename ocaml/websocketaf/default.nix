{ buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/a750056.tar.gz;
    sha256 = "1j807pf3qb4d6nwvx7pl0l2zszswm7zsn9vhyxwnnqrssfn1nci7";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
