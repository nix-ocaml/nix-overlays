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
    if (lib.versionOlder "5.0" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.7-500/merlin-4.7-500.tbz;
          sha256 = "0cfprybsplc3j5sj7jlz3r1gmdkfg3z7n196yxi8ignm9gzinmks";
        }
    else
      builtins.fetchurl {
        url = https://github.com/ocaml/merlin/releases/download/v4.7-414/merlin-4.7-414.tbz;
        sha256 = "0yy0dhya2sg0dz1hglfqirxg1np780vgxgydikpdz2m7169pi1kc";
      };

  buildInputs = [ yojson csexp result ];
}
