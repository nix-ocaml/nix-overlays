{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "9ee47c2b1acad9f632a6e1a23585ed40093935ba";
    sha256 = "sha256-xGNIucWWsIzPYLdjF37zMFadOU3sUpTHQnyLa8HQ+m4=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
