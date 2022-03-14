{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.2.2-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/8d31bd7.tar.gz;
    sha256 = "1fxhb3hpr29avf4fpkgjmgm0i00ypk2lcw47gbbvk7nx3jlhinbg";
  };

  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
