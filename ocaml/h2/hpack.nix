{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "b720a685a54dd7639e91eec06a7b7e5bbb42eb37";
    hash = "sha256-czYpr+8p6zD9mnfLjxyeP1K7TuZxBnyrbfEPUEhRYqI=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
