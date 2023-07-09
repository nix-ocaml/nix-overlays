{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "cf9b5289066476741635d8598b015ac33548c4ea";
    hash = "sha256-HBt7vtx0Wqv4NnjvQ7QGN0gY/stSeBt1j9oQJHBNa2I=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];

  postPatch = ''
    substituteInPlace lib/dune --replace "result" ""
  '';
}
