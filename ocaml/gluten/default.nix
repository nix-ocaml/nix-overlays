{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/e528beb.tar.gz;
    sha256 = "0qhmal6gwxfab3n3bhgr2nn4vm7kj16z7dz891ki5si7936s205z";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
