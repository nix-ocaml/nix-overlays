{ lib
, substituteAll
, ocaml
, dune_2
, buildDunePackage
, dot-merlin-reader
, yojson
, csexp
, result
}:

buildDunePackage {
  pname = "merlin";
  inherit (dot-merlin-reader) src version;

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      dot_merlin_reader = "${dot-merlin-reader}/bin/dot-merlin-reader";
      dune = "${dune_2}/bin/dune";
    })
  ] ++ lib.optional (lib.versionOlder "4.12" ocaml.version) ./camlp-streams.patch;

  buildInputs = [ dot-merlin-reader yojson csexp result ];
}
