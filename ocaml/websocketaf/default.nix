{ buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/websocketaf/archive/5986fbe.tar.gz;
    sha256 = "1dvsa1i3qwlj0fz8wydj7rad5fc17fl4c8gysr977cajb5w6zdxy";
  };
  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
