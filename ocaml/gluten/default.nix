{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/0.3.0.tar.gz;
    sha256 = "1q77iw46hhlp38c8c0lb1a0sh3bn1g2x9cdpf3zd2cq3lr20i482";
  };

  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
