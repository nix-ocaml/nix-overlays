{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "25645ccf0655be0f4dd2f823a8f66d3094044b63";
    hash = "sha256-OOzs0FoaJzLqcQqHIfEUVKMhXc0+taCMSU6PHL2ZRrM=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
