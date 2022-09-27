{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/4c1bea4.tar.gz;
    sha256 = "15vz20my8b8iynpimbb0is6bkzkw99clhiwa8jyigzjiipvzmlpg";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
