{ ocamlVersion, target ? "native" }:
let
  pkgs = import ./boot.nix { };
  inherit (pkgs) lib stdenv;
  ignoredPackages = [
    # camlp4 or not supported in 4.11+
    "bap"
    "bin_prot_p4"
    "bolt"
    "camlp4"
    "camomile_0_8_2"
    "cil"
    "dypgen"
    "earlybird"
    "enumerate"
    "estring"
    "faillib"
    "fieldslib_p4"
    "gtktop"
    "lablgtk_2_14"
    "lablgtk3-gtkspell3"
    "camlimages_4_2_4"
    "lablgtk-extras"
    "magick"
    "mezzo"
    "mlgmp"
    "ocaml_cairo"
    "ocaml_cryptgps"
    "ocaml_data_notation"
    "ocamlnat"
    "ocamlsdl"
    "ocf"
    "omake_rc1"
    "pa_ounit"
    "sqlite3EZ"
    "type_conv_108_08_00"
    "type_conv_109_60_01"
    "variantslib_p4"
    "xtmpl"
    "async_inotify"
    "async_smtp"
    "lwt_camlp4"
    "js_of_ocaml-camlp4"
    "macaque"
    "comparelib"
    "config-file"
    "erm_xmpp"
    "gmetadom"
    "herelib"
    "higlo"
    "js_build_tools"
    "ocaml_optcomp"
    "ocamlscript"
    "ocsigen_deriving"
    "pa_bench"
    "pipebang"
    "stog"
    "type_conv"
    "type_conv_112_01_01"
    "typerep_p4"
    "ulex"
    "lablgl"

    # too long to build or broken
    "z3"
    "nonstd"
    "genspio"
    "lwt-exit"
    "ocaml-r"

    # dune.configurator issue
    "ocamlfuse"
    "google-drive-ocamlfuse"

    # jbuild files
    "facile"
    "ocsigen-start"
    "torch"

    # linking issues?
    "tsdl"
    "owee"
    "spacetime_lib"
    "prof_spacetime"
    "mariadb"
    "caqti-driver-mariadb"

    # graphql incompatible
    "irmin-containers"
    "irmin-graphql"
    "irmin-mirage-graphql"
    "irmin-unix"

    # broken on 4.12
    "accessor_async"
    "ocaml_extlib-1-7-7"

    # unavailable on macOS
    "ocaml-freestanding"
    "mirage-xen"
    "mirage-bootvar-xen"
    "mirage-net-xen"
    "netchannel"

    # doesn't work with my fork of http/af
    "paf"
    "paf-le"
    "paf-cohttp"
    "git-paf"
    "irmin-mirage-git"

    # broken on macOS?
    "llvm"
    "hacl-star-raw"
    "hacl-star"
    "ocaml_libvirt"
    "cairo2"
    "lablgtk3"
    "lablgtk3-gtkspell3"
    "lablgtk3-sourceview3"
    "labltk"
    "camlimages"

    # broken with ppxlib 0.23
    "elpi"

    # broken on OCaml 4.13
    "hol_light"
    "ppx_tools_versioned"
    "ppxfind"
    "ocaml-migrate-parsetree-1-8"
    "ocaml-migrate-parsetree"
    "wasm"
    "pythonlib"

    # Broken / EOL
    "morph"
    "morph_graphql_server"

    # Broken on OCaml 5.00
    "fontconfig"

    # incompatible with newer menhir
    "odate"

    # incompatible with newer yojson
    "refmterr"
    "rely"
  ];

  buildCandidates = pkgs:
    let
      ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";
    in
    lib.filterAttrs
      (n: v:
        let broken =
          if v ? meta && v.meta ? broken then v.meta.broken else false;
        in
        # don't build tezos stuff
        (! ((builtins.substring 0 5 n) == "tezos")) &&
        (! (builtins.elem n ignoredPackages)) &&
        (! broken) &&
        (
          let platforms = (if ((v ? meta) && v.meta ? platforms) then v.meta.platforms else lib.platforms.all);
          in
          (builtins.elem stdenv.system platforms)
        ))
      ocamlPackages;

  targets = {
    native =
      let
        drvs = buildCandidates pkgs;
        otherDrvs = with pkgs; [
          # cockroachdb-21_1_x
          # cockroachdb-21_2_x
          cockroachdb-22_x
          mongodb-4_2
          # nixUnstable
          # esy
        ];
      in
      [ drvs ] ++ otherDrvs;


    musl =
      let drvs = buildCandidates pkgs.pkgsCross.musl64;
      in
      with drvs;
      [
        # just build a subset of the static overlay, with the most commonly used
        # packages
        piaf
        carl
        (carl.override {
          static = true;
        })
        caqti-driver-postgresql
      ];


    arm64 =
      let
        drvs = buildCandidates pkgs.pkgsCross.aarch64-multiplatform-musl;
      in
      with drvs; [
        # just build a subset of the static overlay, with the most commonly used
        # packages
        piaf
        carl
        (carl.override {
          static = true;
        })
        caqti-driver-postgresql
      ];
  };
in

targets."${target}"
