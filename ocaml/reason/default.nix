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
          url = https://github.com/reasonml/reason/archive/ccc34729994b4a80d4f6274cc0165cd9113444d6.tar.gz;
          sha256 = "00hy9wpp7qyjs1nzq0hmjywqsz1xb9360icrrdr32pp9j84bym4i";
        } else
    # Melange depends on the 4.08 AST, and until that's fixed we use this Reason version
      builtins.fetchurl {
        url = https://registry.npmjs.org/@esy-ocaml/reason/-/reason-3.7.0.tgz;
        sha256 = "0spqbsphxnpp3jdy4amfgw58w6mam5gb4vn9gxm5nh9rkcz0iaqg";
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
