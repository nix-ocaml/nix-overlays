{ lib
, fetchpatch
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

  patches = [
    (fetchpatch

      {
        url = "https://github.com/ocaml/merlin/commit/9e0c47b0d5fd0c4edc37c4c7ce927b155877557d.patch";
        hash = "sha256-HmdTISE/s45C5cwLgsCHNUW6OAPSsvQ/GcJE6VDEobs=";
      })
  ];
}
