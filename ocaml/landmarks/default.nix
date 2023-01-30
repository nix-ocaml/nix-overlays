{ buildDunePackage, ppxlib }:

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4";
  src = builtins.fetchurl {
    url = "https://github.com/LexiFi/landmarks/archive/v${version}.tar.gz";
    sha256 = "0wp3p22j7wr2cbm042ba9faf9679013rnmkj3q9xrgjycg0gwjiw";
  };

  patches = [ ./landmarks-m1.patch ];

  propagatedBuildInputs = [ ppxlib ];
}
