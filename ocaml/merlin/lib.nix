{ lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.7";

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
          url = https://github.com/ocaml/merlin/releases/download/v4.8-501preview/merlin-4.8-501preview.tbz;
          sha256 = "1i767437pw7b9l423bj30gyw93iizyvl4i5x884xq189cbb1z46r";
        }
    else
      if (lib.versionOlder "5.0" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.9-500/merlin-4.9-500.tbz;
            sha256 = "09lm37rwbzzh613iga8aqfzqklpsw8w7x4r83ljifkri79mwc1xr";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v4.9-414/merlin-4.9-414.tbz;
          sha256 = "1zfbk5s5289bcpmgf2nxi4n6c2jjisc21j17kpznj4jr2dwc8gz2";
        };

  buildInputs = [ yojson csexp result ];
}
