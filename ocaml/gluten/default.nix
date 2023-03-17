{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/releases/download/0.4.1/gluten-0.4.1.tbz;
    sha256 = "1d1xcw2v3k8g1ifm0wj0ryabgy55qq9g076pgc9c2rjnslzg7rkq";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
