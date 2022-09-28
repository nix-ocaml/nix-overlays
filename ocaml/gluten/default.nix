{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/c4a764f.tar.gz;
    sha256 = "00vij15cnhy6x603nljwlai3gpmzypnd2h4svh7pgdgiswfs67ig";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
