{ lib
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
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if (lib.versionOlder "5.1" ocaml.version) then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.12-501/merlin-4.12-501.tbz;
          sha256 = "1h48j0pvn6mwbrjbkcw47536b8i76y52z2pnyj83ah4pahik7k6c";
        }
    else
      if (lib.versionOlder "5.0" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.12-500/merlin-4.12-500.tbz;
            sha256 = "0zwhcfb33wlzryd4pgwm4daviwf4qys8kmmy1ibsjd3klpn533wg";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v4.12-414/merlin-4.12-414.tbz;
          sha256 = "050xjz5bic1bf03a2wkha83wz6zmdwkxan45dmpf45djh97i80xn";
        };

  buildInputs = [ yojson csexp result ];
}
