{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "3e9625cc5394a4f4d7887b1c478b94ae971d5a81";
    hash = "sha256-ii4ee1xRuLchIw9puudCLD9GgHsm1/H2GxlbeSj/oFI=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
