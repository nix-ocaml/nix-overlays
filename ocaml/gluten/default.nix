{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.2.2-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/faa13c5.tar.gz;
    sha256 = "0d9g92mk508pzh119fgnr1yamvsc0igicbsvdc3glmrlmn4dp7y6";
  };

  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
