{ lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.6";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if (lib.versionOlder "5.0" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/archive/91070ee.tar.gz;
          sha256 = "05m3dq9w99lvadyzcfwgmclzr9x4zmghyamkr13j7nsdi014n2r4";
        }
    else
      builtins.fetchurl {
        url = https://github.com/ocaml/merlin/releases/download/v4.6-414/merlin-4.6-414.tbz;
        sha256 = "1klk0d0j8lzzsp9hlkm8bqafsj54fh3w9r6vcc0r9n3p7h5dgsq2";
      };

  buildInputs = [ yojson csexp result ];
}
