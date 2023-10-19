{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "e8efb527eb92924793615714c973cd9ee32d490b";
    hash = "sha256-7T2VwdNjkqMEAqHlfe0TgroOnj/O/RDdlSy3ySIzXCw=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
