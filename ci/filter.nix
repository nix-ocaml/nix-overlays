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

    "dream-serve"

    "gd4o"

    "ocaml-sat-solvers"

    "pgsolver"
    "tcslib"

    # Not compatible with EIO piaf yet
    "oidc-client"

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
    "ocamlformat_0_25_1"

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

    # takes a long time to build, broken by recent Coq upgrade
    "lambdapi"

    # Broken on janestreet v0.17
    "camlimages"
    "multiformats"

    # cstruct -> string
    "chacha"
    "hyper"
    "matrix-stos"
    "otr"

    # incompatible with newer conduit-lwt-unix
    "websocket-lwt-unix"
    "irmin-server"

    # incompatible with new ppxlib?
    "metapp"

    # flaky?
    "binaryen"
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

    ## Doesn't work with latest lsp on 5.2
    "linol"
    "linol-lwt"
  ];

  darwinIgnores = [
    "dssi"
    "elina"
    "augeas"
    "nbd"

    # broken on macOS?
    "llvm"

    "alsa"
    "mm"

    "uring"
    "eio_linux"

    "inotify"
    "async_inotify"
    "async_smtp"
    "pam"
    "netsnmp"
    "ocaml-probes"

    "gapi-ocaml"
    "bz2"
    "curses"
    "ocaml_libvirt"
    "magic"
    "secp256k1"
    "z3"
    "zelus"
    "zelus-gtk"
    "ocamlfuse"
    "wayland"

    # Broken on janestreet v0.17
    "ecaml"

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
        base cohttp-lwt-unix tls core utop irmin;
    } // (if lib.hasPrefix "5_" ocamlVersion then {
      inherit piaf carl;
      static-carl = carl.override { static = true; };
    } else { }));

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
