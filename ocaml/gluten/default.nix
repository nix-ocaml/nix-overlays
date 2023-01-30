{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/870eb19.tar.gz;
    sha256 = "01p03bp3rcb4n9zi2czcprhsy5495gd9530drcrz7k39b43x8f03";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
