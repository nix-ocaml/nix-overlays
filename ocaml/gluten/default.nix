{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "94e25a211f07ee6c5375669821dfc728bfc6f158";
    sha256 = "ZPRff2ZLnu4QtlfZw0Nwyo172ocsK8yzBDl2EDfhuw0=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
