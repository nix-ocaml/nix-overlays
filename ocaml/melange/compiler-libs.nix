{ buildDunePackage, menhir, menhirLib, ocaml, lib }:

let
  is_412 =
    lib.versionOlder "4.12" ocaml.version &&
    !(lib.versionOlder "4.13" ocaml.version);
  is_414 =
    lib.versionOlder "4.14" ocaml.version &&
    !(lib.versionOlder "5.00" ocaml.version);

in

if is_412 || is_414
then
  buildDunePackage
  {
    pname = "melange-compiler-libs";
    version = "0.0.0";

    src =
      if is_412
      then
        builtins.fetchurl
          {
            url = https://github.com/melange-re/melange-compiler-libs/archive/refs/tags/4.12.0+mel.tar.gz;
            sha256 = "1dby5dglwmfgl1wjqh6jqggj18kmln1npm82913i5shpadz88flz";
          }
      else
        builtins.fetchurl {
          url = https://github.com/melange-re/melange-compiler-libs/archive/2fac95b0ea97fb676240662aeeec8c6f6495dd9c.tar.gz;
          sha256 = "10ija6y9c65h4lzlgnps4514qbbww2r5f566wz83qxwqhaysb3wb";
        };


    propagatedBuildInputs = [ menhir menhirLib ];
  }

else null
