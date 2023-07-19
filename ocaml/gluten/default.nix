{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "d19ca19bc04f37011431665786ab7ca3ea809600";
    hash = "sha256-SzmNs+WpuCHkO2VEgSwHGQAQaF/UVSAkr0KpDiwg2x8=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
