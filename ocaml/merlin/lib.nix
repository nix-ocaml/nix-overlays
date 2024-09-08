{ fetchFromGitHub
, lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
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
    else if (lib.versionOlder "5.2" ocaml.version)
    then
      builtins.fetchurl
        {
          url = "https://github.com/ocaml/merlin/releases/download/v5.1-502/merlin-5.1-502.tbz";
          sha256 = "05dfzhbyjygg8v7i9jgrxbii170mj13k81pam36gz74j4sy0in2g";
        }
    else
      if (lib.versionOlder "5.1" ocaml.version) then
        builtins.fetchurl
          {
            url = "https://github.com/ocaml/merlin/releases/download/v4.16-501/merlin-4.16-501.tbz";
            sha256 = "09hyq8v3hp4f7k0nm6gwpk9dn057l332qmz458lmqr20n04z6nys";
          }
      else
        if (lib.versionOlder "5.0" ocaml.version)
        then
          builtins.fetchurl
            {
              url = "https://github.com/ocaml/merlin/releases/download/v4.14-500/merlin-4.14-500.tbz";
              sha256 = "03nps5mbh5lzf88d850903bz75g5sk33qc3zi7c0qlkmz0jg68zc";
            }
        else
          builtins.fetchurl {
            url = "https://github.com/ocaml/merlin/releases/download/v4.16-414/merlin-4.16-414.tbz";
            sha256 = "0bfgdwk77r11im5n6mvxkl9jp6kh65n3avrh3fg88mnzydsiksf5";
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
