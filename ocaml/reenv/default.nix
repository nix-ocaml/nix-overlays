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
    sha256 = "1yj006vp4nsp8nwhi9m2m7clwj7nj39lr7qgp0660s43q58943di";
  };

  checkInputs = [ alcotest junit junit_alcotest ];

  doCheck = true;

  propagatedBuildInputs = [ reason cmdliner re ];

  meta = {
    description = "dotenv-cli written in reason";
    license = lib.licenses.mit;
  };
}
