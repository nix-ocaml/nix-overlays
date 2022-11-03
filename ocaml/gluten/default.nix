{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/9122863.tar.gz;
    sha256 = "1iaki3d3jgzqd2xflj5cixd50g2y5y14jmdaw11crlrcwkddd1cc";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
