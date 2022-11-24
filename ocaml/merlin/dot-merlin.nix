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
          url = https://github.com/ocaml/merlin/releases/download/v4.7-413/merlin-4.7-413.tbz;
          sha256 = "09c3z6znj61p1mkzl9vjm7m00zgyw34jlhycqbp1490v5rcqcnb9";
        }
    else if (lib.versionOlder "4.12" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.7-412/merlin-4.7-412.tbz;
          sha256 = "0ijgc0a8hmmhpw4vcsklcfy9j018amqvj01g6w5sb50vn5mwhkfi";
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
