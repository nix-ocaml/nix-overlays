{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/870eb19.tar.gz;
    sha256 = "12ix2g5qcinrvj15xdj4k20g6pnhv2p09k4l5rirr7581hk253iq";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
