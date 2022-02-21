{ lib
, substituteAll
, ocaml
, dune_3
, buildDunePackage
, dot-merlin-reader
, yojson
, csexp
, result
}:

# let camlp-streams-patch = if (lib.versionOlder "5.00" ocaml.version)a then

# in
buildDunePackage {
  pname = "merlin";
  inherit (dot-merlin-reader) src version;

  postPatch = ''
    substituteInPlace src/kernel/mconfig_dot.ml --replace \
      'let prog = "dot-merlin-reader"' \
      'let prog = "${dot-merlin-reader}/bin/dot-merlin-reader"'
    substituteInPlace src/kernel/mconfig_dot.ml --replace \
      'let prog = "dune"' \
      'let prog = "${dune_3}/bin/dune"'
    substituteInPlace src/frontend/ocamlmerlin/dune --replace \
      '(libraries ' \
      '(libraries camlp-streams '
  '';

  buildInputs = [ dot-merlin-reader yojson csexp result ];
}
