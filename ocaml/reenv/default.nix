{ lib
, buildDunePackage
, alcotest
, junit
, junit_alcotest
, reason
, cmdliner
, re
}:

buildDunePackage {
  pname = "reenv";
  version = "0.4.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/reenv/archive/64dbee58dbe01c86e24db3bdcb8961fdc178deb1.tar.gz;
    sha256 = "1bv8rxnjnydfrvc55xbywsl98hq664khg5agacyk7ba0r1vlblh6";
  };

  checkInputs = [ alcotest junit junit_alcotest ];

  doCheck = true;

  propagatedBuildInputs = [ reason cmdliner re ];

  meta = {
    description = "dotenv-cli written in reason";
    license = lib.licenses.mit;
  };
}
