{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "4274321af21bcebda11d2cdc5cafa146bbfdb912";
    hash = "sha256-lXgYNdvkEumy8r4UmHrMmgHwSi9F1MJIyh+k24ugNEg=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
