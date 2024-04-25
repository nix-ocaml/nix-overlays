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

    # graphql incompatible
    "irmin-graphql"
    "irmin-mirage-graphql"

    # doesn't work with my fork of http/af
    "paf"
    "paf-le"
    "paf-cohttp"
    "git-paf"
    "git-unix"
    "git-cohttp"
    "git-cohttp-unix"
    "irmin-mirage-git"
    "git-mirage"
    "irmin-git"
    "http-mirage-client"
    "letsencrypt-mirage"

    # broken since OCaml 4.13
    "hol_light"
    "ppx_tools_versioned"

    # Conflicts with cohttp v6 because of the HTTP module
    "eliom"
    "ocsigen-start"
    "ocsigen-toolkit"
    "ocsigen_server"
    "ocsipersist"
    "ocsipersist-pgsql"
    "ocsipersist-sqlite"


    "dream-serve"

    "gd4o"

    "ocaml-sat-solvers"

    "inotify"
    "async_inotify"
    "async_smtp"
    "pgsolver"
    "tcslib"
    "plotkicadsch"

    # Not compatible with EIO yet
    "oidc-client"

    "pam"
    "netsnmp"
    "ocaml-probes"

    "biotk"
    "phylogenetics"
    "biocaml"
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

    # Incompatible with omd 2.0
    "sail"

    # Doesn't build on 4.14. Re-enable when we remove 4.14
    "asai"

    "torch"

    "binaryen"

    # doesn't work with tls >= 0.17.4
    "sendmail"
    "sendmail-lwt"
  ];

  ocaml5Ignores = [
    "erm_xml"
    "gapi-ocaml"
    "lastfm"
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
  ];

  darwinIgnores = [
    "dssi"
    "elina"

    # broken on macOS?
    "llvm"

    "owl"

    "alsa"
    "mm"

    "uring"
    "eio_linux"
    "wayland"

    # x86_64-darwin is broken even with clang11Stdenv
    "gapi-ocaml"
    "bz2"
    "camlimages"
    "curses"
    "ocaml_libvirt"
    "magic"
    "mccs"
    "line-up-words"
    "janestreet_csv"
    "core_profiler"
    "class_group_vdf"
    "secp256k1"
    "sexp"
    "z3"
    "zelus"
    "zelus-gtk"
    "ocamlfuse"


    # broken on aarch64-darwin
    "janestreet_cpuid"
    "stog"
    "stog_asy"
    "stog_markdown"
  ];
in

rec {
  inherit ocaml5Ignores darwinIgnores;
  ocamlCandidates =
    { pkgs
    , ocamlVersion
    , extraIgnores ? if lib.hasPrefix "5_" ocamlVersion
      then ocaml5Ignores
      else [ ]
    }:
    let
      ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";

      ignoredPackages =
        baseIgnoredPackages ++
        lib.optionals stdenv.isDarwin darwinIgnores ++
        extraIgnores;
    in
    lib.filterAttrs
      (n: v':
      if # don't build tezos stuff
        (builtins.substring 0 5 n) == "tezos"
        || (builtins.elem n ignoredPackages)
      then false
      else
        let
          eval_result = builtins.tryEval v';
        in
        if !eval_result.success then false
        else
          (
            let
              v = eval_result.value;
              broken = (v ? meta && v.meta ? broken && v.meta.broken);
            in
            (lib.isDerivation v) && !broken
          ))
      ocamlPackages;

  crossTarget = pkgs: ocamlVersion:
    with (ocamlCandidates {
      inherit pkgs ocamlVersion;
    }); ({
      # just build a subset of the static overlay, with the most commonly used
      # packages
      inherit
        caqti-driver-postgresql ppx_deriving
        base cohttp-lwt-unix tls core core_unix utop irmin
        mirage-crypto-rng-async;
    } // (if lib.hasPrefix "5_" ocamlVersion then {
      inherit piaf carl;
      static-carl = carl.override { static = true; };
    } else { }));

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
