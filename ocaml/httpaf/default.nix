{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "aff2eeaaf4644d97ab94e89a63b709642e952171";
    hash = "sha256-tBk6OfbnBY+coG/EyuNU0Tgr8rWOtNq3XztfwcopsWk=";
  };
}
