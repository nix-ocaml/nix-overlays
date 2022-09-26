{ lib, stdenv }:
let
  baseIgnoredPackages = [
    # camlp4 or not supported in 4.11+
    "bap"
    "camlp4"
    "camomile_0_8_2"
    "cil"
    "dypgen"
    "earlybird"
    "gtktop"
    "lablgtk_2_14"
    "camlimages_4_2_4"
    "lablgtk-extras"
    "magick"
    "mezzo"
    "mlgmp"
    "ocaml_cairo"
    "ocaml_cryptgps"
    "ocamlnat"
    "ocamlsdl"
    "ocf"
    "omake_rc1"
    "xtmpl"
    "lwt_camlp4"
    "js_of_ocaml-camlp4"
    "macaque"
    "config-file"
    "erm_xmpp"
    "gmetadom"
    "herelib"
    "higlo"
    "ocamlscript"
    "ocsigen_deriving"
    "pipebang"
    "stog"
    "ulex"
    "lablgl"

    # too long to build or broken
    "z3"
    "nonstd"
    "ocaml-r"

    "melange-compiler-libs"
    "melange"
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

    # broken since 4.12
    "ocaml_extlib-1-7-7"

    # doesn't work with my fork of http/af
    "paf"
    "paf-le"
    "paf-cohttp"
    "git-paf"
    "irmin-mirage-git"

    # broken with ppxlib 0.23
    "elpi"

    # broken since OCaml 4.13
    "hol_light"
    "ppx_tools_versioned"
    "ocaml-migrate-parsetree-1-8"
    "ocaml-migrate-parsetree"
    "wasm"
    "pythonlib"

    # Broken since OCaml 4.14
    "eliom"
    "ocsigen_server"
    "ocsigen-toolkit"
    "ocsipersist"
    "ocsipersist-pgsql"
    "ocsipersist-sqlite"
    "ogg"
    "theora"
    "flac"
    "speex"
    "opus"
    "vorbis"

    # incompatible with newer menhir
    "odate"

    # https://github.com/mirage/metrics/issues/57
    "metrics-unix"
    "metrics-mirage"

    "dream-serve"

    # incompatible with cmdliner 1.1
    "git-unix"
    "git-cohttp"
    "git-cohttp-unix"

    # maybe nix-build-uncached bug? X requires non-existent output 'out' from Y
    "elina"
    "apron"

    "gd4o"

    "tsdl-image"
    "tsdl-mixer"
    "tsdl-ttf"
    "ocaml-sat-solvers"
    "pg-solver"
    "cpdf"

    # Broken by python transitive dependencies?
    "lablgtk3-gtkspell3"
    "mdx"

    "ocaml-freestanding"
    "mirage-xen"
    "mirage-bootvar-xen"
    "mirage-net-xen"
    "netchannel"

    "duppy"
    "taglib"
    "getopt"
    "soundtouch"

    # Incompatible with ppxlib >= 0.27
    "brisk-reconciler"
    "flex"
    "rebez"
    "reenv"
    "reperf"

    "inotify"
    "async_inotify"
    "async_smtp"
    "pgsolver"
    "tcslib"
    "plotkicadsch"

    "oidc-client"
    "bls12-381-unix"
  ];

  ocaml5Ignores = [
    "async_js"
    "batteries"
    "bonsai"
    "biocaml"
    "bls12-381-unix"
    "camlp5_strict"
    "camlp5"
    "carton-git"
    "carton-lwt"
    "carton"
    "cfstream"
    "cpdf"
    "csvfields"
    "dose3"
    "email_message"
    "erm_xml"
    "fontconfig"
    "functory"
    "gapi-ocaml"
    "getopt"
    "git"
    "gsl"
    "hack_parallel"
    "imagelib"
    "incr_dom"
    "inifiles"
    "irmin-git"
    "lablgtk3-gtkspell3"
    "lablgtk3-sourceview3"
    "lablgtk3"
    "lastfm"
    "lustre-v6"
    "memtrace_viewer"
    "mccs"
    "mirage-block-unix"
    "multiformats"
    "noise"
    "ocaml_oasis"
    "ocaml-protoc"
    "ocaml-recovery-parser"
    "ocaml-sat-solvers"
    "ocaml-vdom"
    "ocamlify"
    "ocamlmod"
    "ocamlnet"
    "ocp-build"
    "ocplib-json-typed-browser"
    "owl-base"
    "owl"
    "parany"
    "parmap"
    "pcap-format"
    "pgocaml_ppx"
    "pgocaml"
    "phylogenetics"
    "piqi-ocaml"
    "piqi"
    "ppx_css"
    "ppx_python"
    "ppx_tools"
    "promise_jsoo"
    "pyml"
    "rdbg"
    "re2_stable"
    "re2"
    "redis-lwt"
    "redis-sync"
    "redis"
    "rfc7748"
    "ringo-lwt"
    "ringo"
    "rope"
    "samplerate"
    "secp256k1"
    "session-redis-lwt"
    "sexp"
    "shexp"
    "sosa"
    "spell"
    "spelll"
    "stdcompat"
    "tar-unix"
    "tar"
    "telegraml"
    "twt"
    "uecc"
    "vg"
    "virtual_dom"
    "vlq"
    "wodan-unix"
    "xenstore-tool"
    "xml-light"
    "zmq-lwt"
    "zmq"
    "labltk"
    "mldoc"

    "ocamlformat"
    "ocamlformat-rpc_0_20_0"
    "ocamlformat-rpc_0_20_1"
    "ocamlformat-rpc_0_21_0"
    "ocamlformat-rpc"

    "metapp"
    "lambdapi"
  ];

  darwinIgnores = [
    "ffmpeg"
    "ffmpeg-av"
    "ffmpeg-avdevice"
    "ffmpeg-avfilter"
    "ffmpeg-avutil"
    "ffmpeg-avcodec"
    "ffmpeg-swscale"
    "ffmpeg-swresample"
    "dssi"

    # broken on macOS?
    "llvm"
    "ocaml_libvirt"
    "labltk"
    "bjack"

    "alsa"
    "ladspa"
    "mm"
    "pulseaudio"
    "eigen"
    "owl-base"
    "owl"

    "gstreamer"
    "uring"
    "eio_linux"
  ];

in

rec {
  inherit ocaml5Ignores darwinIgnores;
  ocamlCandidates =
    { pkgs
    , ocamlVersion
    , disable_eio_linux ? false
    , extraIgnores ? [ ]
    }:
    let
      ocamlPackages =
        let
          opkgs = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";
        in
        # Not sure how to cross-compile eio_linux yet
        if disable_eio_linux
        then
          (opkgs.overrideScope' (oself: osuper: {
            eio_linux = null;
            # eio_main = osuper.eio_main.override { eio_linux = null; };
          }))
        else opkgs;

      ignoredPackages =
        baseIgnoredPackages ++
        lib.optionals stdenv.isDarwin darwinIgnores ++
        extraIgnores;
    in
    lib.filterAttrs
      (n: v:
      let
        broken = if v ? meta && v.meta ? broken then v.meta.broken else false;
        # don't build tezos stuff
      in
      (!((builtins.substring 0 5 n) == "tezos"))
      && (!(builtins.elem n ignoredPackages)) && lib.isDerivation v && (!broken)
      && (
        let
          platforms = (if ((v ? meta) && v.meta ? platforms) then
            v.meta.platforms
          else
            lib.platforms.all);
        in
        builtins.elem stdenv.system platforms
      ))
      ocamlPackages;

  crossTarget = pkgs: ocamlVersion:
    with (ocamlCandidates {
      inherit pkgs ocamlVersion;
      disable_eio_linux = true;
    }); ({
      # just build a subset of the static overlay, with the most commonly used
      # packages
      inherit piaf-lwt caqti-driver-postgresql ppx_deriving;
    } // {
      inherit piaf carl;
      static-carl = carl.override { static = true; };
    });

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
