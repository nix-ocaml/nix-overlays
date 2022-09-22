{ buildDunePackage, alcotest, hmap }:

buildDunePackage {
  version = "0.1.1-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/archi/archive/60f07c6.tar.gz;
    sha256 = "1vd08pq26dxd71f47ly045a6b8gd8hndbgh6fbci1qazsp07rns5";
  };
  pname = "archi";
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ hmap ];
}
