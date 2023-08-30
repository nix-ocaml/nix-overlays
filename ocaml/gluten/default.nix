{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "0c672bf386047e5ce88677f3e5dfc67b7e9c04d9";
    hash = "sha256-NDB92mTncEWr9wJ6h4Ahi6UwdKpg8BZcPxiH7lbnCH8=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
