{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday }:

buildDunePackage {
  pname = "gluten";
  version = "0.5.1";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/releases/download/0.5.1/gluten-0.5.1.tbz;
    sha256 = "15lx1zmkjzawi78qsssjf179p9f5302ygd3i97ay9gyia0q1p5sm";
  };
  propagatedBuildInputs = [ bigstringaf faraday ];
}
