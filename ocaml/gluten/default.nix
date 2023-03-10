{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "41f6a3d6eb82b804e95ad0d5cd115be5e0e5c7fe";
    hash = "sha256-7QlhoHNeuhnx3yNViS4jjOo/Xigq62RitqXjQwlwmGA=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
