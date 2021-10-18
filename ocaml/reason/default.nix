{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.7.0";

  src =
    if (lib.versionOlder "4.13" ocaml.version) then
      builtins.fetchurl
        {
          # https://github.com/reasonml/reason/pull/2657 -- OCaml 4.13 support
          url = https://github.com/reasonml/reason/archive/8ea317b073.tar.gz;
          sha256 = "050a6bsx1bwrc73p732kpdydcbhflv1ddg39pnlnzqf90pvmgli1";
        } else
    # Melange depends on the 4.08 AST, and until that's fixed we use this Reason version
      builtins.fetchurl {
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
