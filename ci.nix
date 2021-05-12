{ ocamlVersion, target ? "native" }:
let
  pkgs = import ./sources.nix { };
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
    "lablgtk"
    "lablgtk3"
    "lablgtk3-gtkspell3"
    "camlimages"
    "lablgtk3-sourceview3"
    "lablgtk-extras"
    "lens"
    "magick"
    "mezzo"
    "mlgmp"
    "ocaml_cairo"
    "ocaml_cryptgps"
    "ocaml_data_notation"
    "ocaml_http"
    "ocamlnat"
    "ocamlsdl"
    "ocf"
    "omake_rc1"
    "pa_ounit"
    "sodium"
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
    "labltk"

    # too long to build or broken
    "z3"
    "nonstd"
    "sosa"
    "genspio"

    # too outdated / dont care for now
    "wodan-irmin"

    # dune.configurator issue
    "cairo2"
    "ocamlfuse"
    "google-drive-ocamlfuse"

    # jbuild files
    "facile"
    "ocsigen-start"
    "torch"

    # linking issues?
    "ocaml_libvirt"
    "ocaml-r"
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

    # not ppxlib >= 0.18 compatible (I don't use these, so I haven't bothered
    # to fix them)
    "ppx_deriving_rpc"
    "rpclib-lwt"
    "elpi"

    # broken on 4.12
    "accessor_core"
    "accessor_async"
    "ocaml_extlib-1-7-7"

    # unavailable on macOS
    "ocaml-freestanding"
    "mirage-xen"
    "mirage-bootvar-xen"
    "mirage-net-xen"
    "netchannel"

    # broken
    "httpaf-mirage"
    "h2-mirage"
    "websocketaf-mirage"

    # doesn't work with my fork of http/af
    "paf"
    "git-paf"
    "mirage-git"
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
        cockroachdb-drvs = with pkgs; [
          # cockroachdb-20_x
          cockroachdb-21_x
        ];
      in
      [ drvs ] ++ cockroachdb-drvs;


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
