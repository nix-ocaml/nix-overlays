{ lib, stdenv }:
let
  baseIgnoredPackages = [
    # not supported in 4.11+
    "bap"
    "lwt_camlp4"
    "macaque"
    "config-file"
    "erm_xmpp"
    "ulex"
    "lablgl"

    # dune.configurator issue
    "google-drive-ocamlfuse"

    # linking issues?
    "mariadb"
    "caqti-driver-mariadb"

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

    # Broken since OCaml 4.14
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
    "graphql-async"
    "magic-trace"
    "telegraml"

    # Old mirage-kv interface
    "mirage-fs"

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

    # Incompatible with EIO v0.12
    "cohttp-eio"
  ];

  ocaml5Ignores = [
    "erm_xml"
    "fontconfig"
    "gapi-ocaml"
    "lastfm"
    "ocaml_expat"
    "ocaml_oasis"
    "ocamlify"
    "ocp-build"
    "owl"
    "piqi"
    "piqi-ocaml"
    "lambdapi"

    # broken on 5.1
    "labltk"
  ];

  darwinIgnores = [
    "dssi"
    "elina"

    # broken on macOS?
    "llvm"

    "alsa"
    "mm"
    "owl"

    "lambdapi"
    "why3"

    "uring"
    "eio_linux"
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
