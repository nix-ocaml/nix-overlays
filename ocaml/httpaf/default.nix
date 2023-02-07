{ fetchFromGitHub
, buildDunePackage
, angstrom
, faraday
,
}:
buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "7189cd28e21203117f0c8e2347ae9a2fe0e0c157";
    sha256 = "iQk+8aETUuJ2SlRwCThTEVKWX0moGDCagkASHfyuExo=";
  };
}
