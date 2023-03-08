{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "f8b88c4";
    hash = "sha256-wPatuA8L7YO2MR9nIHvaF2d/ty9/BarD8QLUqCEslvM=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
