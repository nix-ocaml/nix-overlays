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
            url = https://github.com/melange-re/melange-compiler-libs/archive/83e3017.tar.gz;
            sha256 = "02h0gzhk6bdxy6iarp8lk6yl80cskxiraqmbplpa5nqn7r9h2d3l";
          }
      else
        builtins.fetchurl {
          url = https://github.com/melange-re/melange-compiler-libs/archive/39d7060.tar.gz;
          sha256 = "0cjjrn65xcvj3298hcn4lpf5r5cm4c61sxpzp8xagl534gbwjyhp";
        };


    propagatedBuildInputs = [ menhir menhirLib ];
  }

else null
