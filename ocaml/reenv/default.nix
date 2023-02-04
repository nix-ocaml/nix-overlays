{ lib
, fetchFromGitHub
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
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "reenv";
    rev = "64dbee58dbe01c86e24db3bdcb8961fdc178deb1";
    sha256 = "sha256-p+RyVAmIEhUlRhLVrWJcrlcJ4fcyVbgo8YxZ0DT2c2w=";
  };

  checkInputs = [ alcotest junit junit_alcotest ];

  doCheck = true;

  nativeBuildInputs = [ reason ];
  propagatedBuildInputs = [ cmdliner re ];

  meta = {
    description = "dotenv-cli written in reason";
    license = lib.licenses.mit;
  };
}
