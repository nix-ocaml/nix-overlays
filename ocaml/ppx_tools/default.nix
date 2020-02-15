{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ppx_tools";
  version = "6.0+4.08.0";

  src = fetchFromGitHub {
    owner = "ocaml-ppx";
    repo = "ppx_tools";
    rev = version;
    sha256 = "056cmdajap8mbb8k0raj0cq0y4jf7pf5x0hlivm92w2v7xxf59ns";
  };
}
