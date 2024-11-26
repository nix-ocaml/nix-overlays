{ fetchFromGitHub
, lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
, merlin
}:

let
  merlinVersion = "4.12";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";
  isFlambda2 = lib.hasSuffix "flambda2" ocaml.version;
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if isFlambda2 then
      fetchFromGitHub
        {
          owner = "janestreet";
          repo = "merlin-jst";
          rev = "65b4861209ab76f065a88b59ed3fdc44b7a03f5a";
          hash = "sha256-+wuVILkh8xJAIdGVDwi/IjubhzBcTRcWkE8v2euaUgQ=";
        }
    else if lib.versionOlder "5.3" ocaml.version
    then
      fetchFromGitHub
        {
          owner = "ocaml";
          repo = "merlin";
          rev = "3438e34a77bd1c3c7a10bffa0c45c419ff91286f";
          hash = "sha256-EZu/9cOtHMO5jIT2RUEC3EZuCcDRyhXHSihxl29sD6s=";
        }
    else if lib.versionOlder "5.2" ocaml.version
    then
      builtins.fetchurl
        {
          url = "https://github.com/ocaml/merlin/releases/download/v5.3-502/merlin-5.3-502.tbz";
          sha256 = "1g14maryp5aw02a0chj9xqbdkky125g4y38cxwqnxylp4gqldsic";
        }
    else if lib.versionOlder "5.1" ocaml.version
    then
      builtins.fetchurl
        {
          url = "https://github.com/ocaml/merlin/releases/download/v4.17.1-501/merlin-4.17.1-501.tbz";
          sha256 = "0055n11ghrxypd6fjx67fnnwj8csp3jgplsnjiiyj28zhym0frrp";
        }
    else if lib.versionOlder "5.0" ocaml.version
    then
      builtins.fetchurl
        {
          url = "https://github.com/ocaml/merlin/releases/download/v4.14-500/merlin-4.14-500.tbz";
          sha256 = "03nps5mbh5lzf88d850903bz75g5sk33qc3zi7c0qlkmz0jg68zc";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v4.18-414/merlin-4.18-414.tbz";
        sha256 = "1h8cwdzvcyxdr6jkpsj7sn2r31aw2g4155l63a63a7hlcsiggmpn";
      };

  postPatch =
    if isFlambda2 then ''
      # not sure what this file is doing, but it causes a duplicate symbol
      # linking error
      truncate --size=0 src/runtime/float32.c

      substituteInPlace src/frontend/dune --replace-fail \
        "merlin_specific" "merlin_specific merlin_extend"
    '' else "";
  buildInputs = [ yojson csexp result ];
}
