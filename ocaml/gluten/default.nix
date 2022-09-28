{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/1e5c83a1.tar.gz;
    sha256 = "1iriyvkc2l6yp2k2np8c8y1zyiv46png4mg9cfmd2401g0gc8aph";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
