{ buildDunePackage, ppxlib }:

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4";
  src = builtins.fetchurl {
    url = "https://github.com/LexiFi/landmarks/archive/v${version}.tar.gz";
    sha256 = "0dnakz18lcgfd4pfjqjg6w5nh2qby45z0xp7d7qqgzlgj991b20d";
  };

  patches = [ ./landmarks-m1.patch ];

  propagatedBuildInputs = [ ppxlib ];
}
