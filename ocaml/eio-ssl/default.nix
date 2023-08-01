{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "19bc32c2aa2d3ad5917993f4e676f06344f7cb17";
    hash = "sha256-YiEjWFKGvNM/K3o2EJgVbwGhMhXTgxX+AEk3Isd8seM=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
