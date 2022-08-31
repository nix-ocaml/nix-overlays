{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/cdd36f9.tar.gz;
    sha256 = "1mgxp5w873fvf90vdsll614yx1jdkj7v6idx0702wdj1z99i9mka";
  };
}
