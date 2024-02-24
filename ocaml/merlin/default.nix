{ lib
, substituteAll
, ocaml
, dune_3
, buildDunePackage
, dot-merlin-reader
, yojson
, csexp
, result
, merlin-lib
, camlp-streams
}:

buildDunePackage {
  pname = "merlin";
  inherit (dot-merlin-reader) src version;

  buildInputs = [ dot-merlin-reader yojson csexp result camlp-streams ];
}
