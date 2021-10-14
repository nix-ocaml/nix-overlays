{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.7.0";

  src = builtins.fetchurl {
    url = https://github.com/reasonml/reason/archive/ccc34729994b4a80d4f6274cc0165cd9113444d6.tar.gz;
    sha256 = "00hy9wpp7qyjs1nzq0hmjywqsz1xb9360icrrdr32pp9j84bym4i";
  };

  propagatedBuildInputs = [
    menhir
    menhirLib
    menhirSdk
    fix
    merlin-extend
    ppx_derivers
    result
  ];

  nativeBuildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
