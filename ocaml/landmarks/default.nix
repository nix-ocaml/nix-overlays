{ fetchFromGitHub, lib, buildDunePackage, ppxlib }:

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4";
  src = fetchFromGitHub {
    owner = "LexiFi";
    repo = "landmarks";
    rev = "v${version}";
    sha256 = "sha256-2YvSMR5y1uk+OQ/h4IPIYYAGb64FRIM7glSPpa8YAkw=";
  };

  patches = [ ./landmarks-m1.patch ];

  propagatedBuildInputs = [ ppxlib ];
}
