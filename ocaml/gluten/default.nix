{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "c4be3c506a7bbe77774a7ce621323912f45e854f";
    hash = "sha256-In7HUosyLl039Y4m5F06lwwpGbvOxmWLwr9V3I3JE8M=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
