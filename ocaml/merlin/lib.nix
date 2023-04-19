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
            url = https://github.com/ocaml/merlin/releases/download/v4.8-500/merlin-4.8-500.tbz;
            sha256 = "08lcx6m0rhfx9f97568g5pancz2vlx5b5mpfgmk5dzilx8m4g4wz";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v4.8-414/merlin-4.8-414.tbz;
          sha256 = "1bwbg6k9i1vjf5br5dbn7fd0xwbi86rxwy1dycwnspafqn2xdi8w";
        };

  buildInputs = [ yojson csexp result ];
}
