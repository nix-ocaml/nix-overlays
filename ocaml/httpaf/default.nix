{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "e7936f9";
    hash = "sha256-PMx+ZvdZ6RCNPz49O4DSiHm5uJjWbed9hFN7ps/xxdA=";
  };
}
