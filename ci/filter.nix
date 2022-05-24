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
    "genspio"
    "ocaml-r"

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

    # broken on 4.12
    "accessor_async"
    "ocaml_extlib-1-7-7"

    # unavailable on macOS
    "ocaml-freestanding"
    "mirage-xen"
    "mirage-bootvar-xen"
    "mirage-net-xen"
    "netchannel"
    "ffmpeg"
    "ffmpeg-av"
    "ffmpeg-avdevice"
    "ffmpeg-avfilter"
    "ffmpeg-avutil"
    "ffmpeg-avcodec"
    "ffmpeg-swscale"
    "ffmpeg-swresample"
    "dssi"

    # doesn't work with my fork of http/af
    "paf"
    "paf-le"
    "paf-cohttp"
    "git-paf"
    "irmin-mirage-git"

    # broken on macOS?
    "llvm"
    "ocaml_libvirt"
    "labltk"
    "camlimages"
    "bjack"
    "async_inotify"
    "async_smtp"

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

    # incompatible with newer yojson
    "reason-native"

    # Incompatible with JSOO 4
    "bonsai"

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

    # incompatible with ppxlib 0.26
    "ppx_deriving_bson"

    "gd4o"
  ];

  ocaml412Ignores = [
    "typedppxlib"
    "ppx_debug"
  ];

  ocaml5Ignores = [
    "async_js"
    "batteries"
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
    "gapi_ocaml"
    "getopt"
    "git"
    "gsl"
    "hack_parallel"
    "imagelib"
    "incr_dom"
    "inifiles"
    "inotify"
    "irmin-git"
    "js_of_ocaml-compiler"
    "js_of_ocaml-lwt"
    "js_of_ocaml-ppx_deriving_json"
    "js_of_ocaml-ppx"
    "js_of_ocaml-tyxml"
    "js_of_ocaml"
    "lablgtk3-gtkspell3"
    "lablgtk3-sourceview3"
    "lablgtk3"
    "lastfm"
    "lustre-v6"
    "mccs"
    "mirage-block-unix"
    "multiformats"
    "noise"
    "ocaml_oasis"
    "ocaml-protoc"
    "ocaml-recovery-parser"
    "ocaml-sat-solvers"
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
    "pgsolver"
    "phylogenetics"
    "piqi-ocaml"
    "piqi"
    "ppx_css"
    "ppx_python"
    "ppx_tools"
    "pyml"
    "rdbg"
    "re2_stable"
    "re2"
    "reactivedata"
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
    "sha"
    "shexp"
    "sosa"
    "spell"
    "spelll"
    "stdcompat"
    "stdint"
    "tar-unix"
    "tar"
    "tcslib"
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
  ];

  aarch64DarwinIgnores = [
    "landmarks"
    "landmarks-ppx"
  ];
in

rec {
  inherit ocaml5Ignores ocaml412Ignores aarch64DarwinIgnores;
  ocamlCandidates = { pkgs, ocamlVersion, extraIgnores ? [ ] }:
    let
      ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";
      ignoredPackages = baseIgnoredPackages ++ extraIgnores;
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
    with (ocamlCandidates { inherit pkgs ocamlVersion; }); {
      # just build a subset of the static overlay, with the most commonly used
      # packages
      inherit piaf carl caqti-driver-postgresql ppx_deriving;
      static-carl = carl.override { static = true; };
    };

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
