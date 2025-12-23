{
  fetchFromGitHub,
  buildDunePackage,
  bigstringaf,
  faraday,
}:

buildDunePackage {
  pname = "gluten";
  version = "0.5.2";

  src = builtins.fetchurl {
    url = "https://github.com/anmonteiro/gluten/releases/download/0.5.2/gluten-0.5.2.tbz";
    sha256 = "0pq1ww3p41m6dzk2cmrr7pq03kvb5hjqvk49s95vp030kygxivmi";
  };
  propagatedBuildInputs = [
    bigstringaf
    faraday
  ];
}
