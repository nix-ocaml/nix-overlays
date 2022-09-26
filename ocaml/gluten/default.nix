{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/7f63e7c.tar.gz;
    sha256 = "0m62r4bywhw0c9d92cdiw0bf71miq0avah27bi07cxw5pfkahc1h";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
