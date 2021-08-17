{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/de78358.tar.gz;
    sha256 = "1m8hlc08bki393zyd9vpm4m0cs2j097i0jgmbljxl87in4wi9pr3";
  };
}
