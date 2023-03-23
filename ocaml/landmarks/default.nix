{ fetchFromGitHub, lib, buildDunePackage, ppxlib }:

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4";
  src = fetchFromGitHub {
    owner = "LexiFi";
    repo = "landmarks";
    rev = "cd772ed6f44b8419b708a6f014a12bf8a416ef84";
    hash = "sha256-oCxtU5sWEFX9fCdE8WKFvH/0Vp4xE7fMmUtZOjjs4jI=";
  };

  propagatedBuildInputs = [ ppxlib ];
}
