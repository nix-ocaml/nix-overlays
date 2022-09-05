{ lib
, ocaml
, findlib
, buildDunePackage
, yojson
, csexp
, result
, merlin-lib
}:

buildDunePackage {
  pname = "dot-merlin-reader";
  version =
    if lib.versionAtLeast ocaml.version "4.14" then
      merlin-lib.version else "n/a";

  src =
    if lib.versionAtLeast ocaml.version "4.14" then
      merlin-lib.src
    else if (lib.versionOlder "4.13" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.6-413/merlin-4.6-413.tbz;
          sha256 = "1vlhgljcsdnyh9c5kxjvhwn24wbm56bmwddcv3pmzs64hhgkgpgk";
        }
    else if (lib.versionOlder "4.12" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.6-412/merlin-4.6-412.tbz;
          sha256 = "15vbckvxr9wgbwfx96h4ly9xab1w95xa0y04874jk6lnnynaxj4a";
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

  propagatedBuildInputs = [ yojson csexp result merlin-lib findlib ];
}
