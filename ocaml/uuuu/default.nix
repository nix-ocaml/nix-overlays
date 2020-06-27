{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "uuuu";

  version = "0.2.0";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/uuuu/releases/download/v${version}/uuuu-v${version}.tbz";
    sha256 = "0czgg2hp8r4r0piki193cl94gyqa28jvk51c2k9x7cjlr16nr327";
  };

  propagatedBuildInputs = [
    menhir
    angstrom
  ];
}
