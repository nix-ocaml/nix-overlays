{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/b8adb3b8.tar.gz;
    sha256 = "15njjgzk68yx6xgva67f54z5v7b08iaavg2pgk5ji71i5xm0d9v1";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
