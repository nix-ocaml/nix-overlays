{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/d3ce6b0ab7.tar.gz;
    sha256 = "0pz8ajx7pkh913p2kjn5pfppnfv9kji98kfwq28kq6mvkqc63984";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
