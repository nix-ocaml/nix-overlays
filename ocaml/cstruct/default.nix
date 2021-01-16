{ osuper, oself }:

let
  src = builtins.fetchurl {
    url = https://github.com/mirage/ocaml-cstruct/releases/download/v6.0.0/cstruct-v6.0.0.tbz;
    sha256 = "0xi6cj85z033fqrqdkwac6gg07629vzdhx03c3lhiwwc4lpnv8bq";
  };
  overrideCstruct = pname: osuper."${pname}".overrideAttrs (o: {
    inherit src;
  });

in

with oself;
{
  cstruct = overrideCstruct "cstruct";

  cstruct-lwt = overrideCstruct "cstruct-lwt";

  cstruct-sexp = overrideCstruct "cstruct-sexp";

  cstruct-unix = overrideCstruct "cstruct-unix";

  ppx_cstruct = (overrideCstruct "ppx_cstruct").overrideAttrs (o: {
    propagatedBuildInputs = [ cstruct ppxlib sexplib ];
  });
}
