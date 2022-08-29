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

    substituteInPlace src/utils/std.ml --replace \
      ' = capitalize' ' = capitalize_ascii'
    substituteInPlace src/utils/std.ml --replace \
      ' = uncapitalize' ' = uncapitalize_ascii'
    substituteInPlace src/utils/std.ml --replace \
      ' = lowercase' ' = lowercase_ascii'
    substituteInPlace src/utils/std.ml --replace \
      ' = uppercase' ' = uppercase_ascii'

    substituteInPlace src/config/gen_config.ml --replace \
      '| `OCaml_4_14_0 ] = %s' '| `OCaml_4_14_0 | `OCaml_5_0_0 ] = %s'
  '';

  buildInputs = [ dot-merlin-reader yojson csexp result camlp-streams ];
}
