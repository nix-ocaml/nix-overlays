{ fetchFromGitHub, ocamlPackages }:

ocamlPackages.buildDunePackage {
  pname = "archi";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "6cbaaa7340aaceec7eaaa9a597da6e1bbcb10fb3";
    sha256 = "0g09h1lnzsr4ggxwf6ccpkbllg5f8ai45f6lypkwigmgzkrddsz1";
  };

  propagatedBuildInputs = with ocamlPackages; [
    hmap
    lwt4
  ];
}

