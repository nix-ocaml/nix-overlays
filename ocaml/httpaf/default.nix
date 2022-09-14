{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/3781a12.tar.gz;
    sha256 = "13i410s7jpb9fvzkjh60ql5sgs7m8pisbhw96frm1zqlrpk0wq2d";
  };
}
