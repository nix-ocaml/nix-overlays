{ lib, stdenv }:
let
  baseIgnoredPackages = [
    # not supported in 4.11+
    "bap"
    "lwt_camlp4"
    "config-file"
    "erm_xmpp"
    "ulex"

    # dune.configurator issue
    "google-drive-ocamlfuse"

    # doesn't work with cohttp 6.0
    "paf-cohttp"

    # broken since OCaml 4.13
    "ppx_tools_versioned"

    # Conflicts with cohttp v6 because of the HTTP module
    "eliom"
    "ocsigen-start"
    "ocsigen-toolkit"
    "ocsigen_server"
    "ocsipersist"
    "ocsipersist-pgsql"
    "ocsipersist-sqlite"
    "ocsipersist-sqlite-config"
    "ocsipersist-pgsql-config"

    "dream-serve"

    "gd4o"

    "ocaml-sat-solvers"

    "pgsolver"
    "tcslib"

    "pythonlib"
    "magic-trace"

    # too old ocamlformat versions
    "ocamlformat_0_19_0"
    "ocamlformat_0_20_0"
    "ocamlformat_0_20_1"
    "ocamlformat_0_21_0"
    "ocamlformat_0_22_4"
    "ocamlformat_0_23_0"
    "ocamlformat_0_24_1"
    "ocamlformat_0_25_1"
    "ocamlformat_0_26_0"
    "ocamlformat_0_26_1"
    "ocamlformat_0_26_2"

    # Incompatible with omd 2.0
    "sail"

    # Doesn't build on 4.14. Re-enable when we remove 4.14
    "asai"

    "torch"

    # we don't really care about these and they don't build on 4.14
    "spices"
    "gluon"
    "rio"
    "bytestring"
    "config"
    "libc"
    # build is broken, something with tls
    "riot"
    "minttea"
    "opium"
    "rock"
    "subscriptions-transport-ws"

    # long time to build
    "lambdapi"
    "ocaml_libvirt"
    "unisim_archisec"
    "smtml"
    "z3"
    "frama-c"
    "frama-c-lannotate"
    "frama-c-luncov"
    "eigen"
    "owl"
    "owl-base"
    "symex"

    # Broken on janestreet v0.17
    "multiformats"

    # cstruct -> string
    "chacha"
    "hyper"
    "matrix-stos"

    # incompatible with newer conduit-lwt-unix
    "websocket-lwt-unix"
    "irmin-server"

    # incompatible with new ppxlib?
    "metapp"

    # not compatible with latest odoc
    "sherlodoc"

    "odds"
    "raylib"
    "raygui"

    "miou"
    "multipart_form-miou"
    "multipart_form-eio"
    "mirage-crypto-rng-miou-unix"
    "tls-miou-unix"
    "happy-eyeballs-miou-unix"
    "httpcats"
    "dns-client-miou-unix"

    "virtual_dom_toplayer"
    "ppx_css"
    "bonsai"
    "memtrace_viewer"

    "ppx_python"
    "pyml"

    # Broken with JSOO 6.1
    "incr_dom"
    "incr_dom_interactive"
    "incr_dom_sexp_form"
    "incr_map"
    "parsexp_io"
    "codicons"
    "js_of_ocaml_patches"
    "virtual_dom"
    "incr_dom_partial_render"
    "ppx_yojson_conv"
    "get-activity"
    "get-activity-lib"
    "babel"
    "polling_state_rpc"
    "versioned_polling_state_rpc"
    "diffable"
    "legacy_diffable"
    "ocaml_openapi_generator"

    "flow_parser"
    "ppx_jsx_embed"
    "ppx_deriving_bson"
    "brisk-reconciler"
    "bistro"

    # broken with latest camlp5
    "hol_light"

    # broken on 5.5 / lwt > 6.0
    "tezt"
  ];

  ocaml5Ignores = [
    "erm_xml"
    "gapi-ocaml"
    "memprof-limits"
    "ocaml_oasis"
    "ocamlify"
    "ocp-build"
    "piqi"
    "piqi-ocaml"

    # broken on 5.1
    "labltk"
    "ocaml-migrate-parsetree-2"
    "ocaml-migrate-types"
    "ppx_debug"
    "typedppxlib"

    # broken on 5.3
    "ppx_cstubs"
    "reanalyze"

    # website down?
    "lutils"
    "lustre-v6"
    "rdbg"
  ];

  darwinIgnores = [
    "dssi"
    "elina"
    "augeas"
    "gapi-ocaml"
    "nbd"

    # broken on macOS?
    "llvm"
    "mopsa"

    "alsa"
    "mm"

    "uring"
    "eio_linux"

    "inotify"
    "async_inotify"
    "async_smtp"
    "pam"
    "ocaml-probes"
    "systemd"

    "zelus"
    "zelus-gtk"
    "ocamlfuse"

    # Broken on janestreet v0.17
    "ecaml"

    # broken on aarch64-darwin
    "janestreet_cpuid"
    "stog"
    "stog_asy"
    "stog_markdown"

    # Broken on latest SDK update?
    "soundtouch"
    "taglib"

    # temporarily broken in nixpkgs?
    "netsnmp"
  ];
in

rec {
  inherit ocaml5Ignores darwinIgnores;
  ocamlCandidates =
    {
      pkgs,
      ocamlVersion,
      extraIgnores ? if lib.hasPrefix "5_" ocamlVersion then ocaml5Ignores else [ ],
    }:
    let
      ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";

      ignoredPackages =
        baseIgnoredPackages ++ lib.optionals stdenv.isDarwin darwinIgnores ++ extraIgnores;
    in
    lib.filterAttrs (
      n: v':
      # don't build tezos stuff
      if (builtins.substring 0 5 n) == "tezos" || (builtins.elem n ignoredPackages) then
        false
      else
        let
          eval_result = builtins.tryEval v';
        in
        if !eval_result.success then
          false
        else
          (
            let
              v = eval_result.value;
              broken = (v ? meta && v.meta ? broken && v.meta.broken);
            in
            (lib.isDerivation v) && !broken
          )
    ) ocamlPackages;

  crossTarget =
    pkgs: ocamlVersion:
    with (ocamlCandidates {
      inherit pkgs ocamlVersion;
    });
    (
      {
        # just build a subset of the static overlay, with the most commonly used
        # packages
        inherit
          caqti-driver-postgresql
          ppx_deriving
          base
          cohttp-lwt-unix
          tls
          core
          utop
          irmin
          ;
      }
      // (
        if lib.hasPrefix "5_" ocamlVersion then
          {
            inherit piaf carl;
            static-carl = carl.override { static = true; };
          }
        else
          { }
      )
    );

  crossTargetList =
    pkgs: ocamlVersion:
    let
      attrs = crossTarget pkgs ocamlVersion;
    in
    lib.attrValues attrs;
}
