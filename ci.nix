{ ocamlVersion }:

let
  pkgs = import ./sources.nix {};
  inherit (pkgs) lib stdenv;
  ignoredPackages = [
    "bap" "bin_prot_p4" "bolt" "camlp4" "camomile_0_8_2" "cil"
    "dypgen" "earlybird" "enumerate" "estring" "faillib" "fieldslib_p4" "gtktop"
    "lablgtk_2_14" "lens" "magick" "mezzo" "mlgmp" "ocaml_cairo" "ocaml_cryptgps"
    "ocaml_data_notation" "ocaml_http" "ocamlnat" "ocamlsdl" "ocf" "omake_rc1"
    "pa_ounit" "ppx_deriving_protobuf" "sodium" "sqlite3EZ" "type_conv_108_08_00"
    "type_conv_109_60_01" "variantslib_p4" "xtmpl" "async_inotify" "async_smtp"
    "lwt_camlp4" "js_of_ocaml-camlp4" "macaque" "odn" "comparelib" "config-file"
    "erm_xmpp" "gmetadom" "herelib" "higlo" "js_build_tools" "lablgtk-extras"
    "lua-ml" "ocaml_optcomp" "ocamlscript" "ocsigen_deriving" "pa_bench" "pipebang"
    "rope" "stog" "type_conv" "type_conv_112_01_01" "typerep" "typerep_p4" "ulex"
    "lablgl"
  ];

in

  lib.filterAttrs
  (n: v:
  let broken = if v ? meta && v.meta ? broken then v.meta.broken else false; in
  ((! (builtins.elem n ignoredPackages)) &&
   (! broken) &&
  (let platforms = (if ((v ? meta) && v.meta ? platforms) then v.meta.platforms else lib.platforms.all);
    in
    (builtins.elem stdenv.system platforms)))
  )
    pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}"

