{ lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.4";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";

in

buildDunePackage {
  pname = "dot-merlin-reader";
  version = version;
  src =
    if (lib.versionOlder "5.00" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/archive/fce8fb220c6677a4e1f1677efa2e5b5b13f12254.tar.gz;
          sha256 = "1n53b7isla3jyva3kpizxrmyjja6w62c2p799lzla2jy96ldjpcj";
        }
    else if (lib.versionOlder "4.14" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/archive/82723b88659112e76f8da78830243e4c557c60f5.tar.gz;
          sha256 = "1yd70s78a3csacmn9zs9z2qhqghc6844ly5c5lzgghib304sw75l";
        }
    else if (lib.versionOlder "4.13" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.4-413/merlin-4.4-413.tbz;
          sha256 = "1ilmh2gqpwgr51w2ba8r0s5zkj75h00wkw4az61ssvivn9jxr7k0";
        }
    else if (lib.versionOlder "4.12" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.4-412/merlin-4.4-412.tbz;
          sha256 = "18xjpsiz7xbgjdnsxfc52l7yfh22harj0birlph4xm42d14pkn0n";
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

  postPatch = ''
    substituteInPlace src/utils/std.ml --replace "= capitalize" "= capitalize_ascii"
    substituteInPlace src/utils/std.ml --replace "= uncapitalize" "= uncapitalize_ascii"
    substituteInPlace src/utils/std.ml --replace "= lowercase" "= lowercase_ascii"
    substituteInPlace src/utils/std.ml --replace "= uppercase" "= uppercase_ascii"
  '';

  buildInputs = [ yojson csexp result ];
}
