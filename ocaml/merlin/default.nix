{ ocamlPackages, lib, substituteAll }:

with ocamlPackages;

let
  merlinVersion = "4.1";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";

in

buildDunePackage {
  pname = "merlin";
  version = version;
  src =
    if (lib.versionOlder "4.13" ocaml.version) then
      builtins.fetchurl
        {
          url = https://github.com/kit-ty-kate/merlin/archive/38c13ee8907c84fd26245c7e06d03f370b2d7e74.tar.gz;
          sha256 = "0anm7vmx4qbz3hs2aah5zfv3lgpkbj9chxswlnh166x8m0n77fll";
        }
    else
      if (lib.versionOlder "4.12" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.1-412/merlin-v4.1-412.tbz;
            sha256 = "13cx0v999ijj48m2zb0rsgi1m42bywm7jc8fsqxkkf5xfggawk7v";
          }
      else if (lib.versionOlder "4.11" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.1-411/merlin-v4.1-411.tbz;
            sha256 = "0zckb729mhp1329bcqp0mi1lxxipzbm4a5hqqzrf2g69k73nybly";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v3.4.2/merlin-v3.4.2.tbz;
          sha256 = "109ai1ggnkrwbzsl1wdalikvs1zx940m6n65jllxj68in6bvidz1";
        };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      dot_merlin_reader = "${dot-merlin-reader}/bin/dot-merlin-reader";
      dune = "${dune_2}/bin/dune";
    })
  ];

  buildInputs = [ dot-merlin-reader yojson csexp result ];

}
