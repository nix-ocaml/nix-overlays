{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "691d2d7998d3fc7e39e55270a7157220c78ca832";
    hash = "sha256-nVBcY//nXaYscU4eGpto5fzMojzJax5UzNxF+dG5E4w=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
