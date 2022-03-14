{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/395aad2bc4.tar.gz;
    sha256 = "0m7nfynmwikxixaa1y0k44ngy5s2j2zf906q6v7vcvgd1igh9a1m";
  };
}
