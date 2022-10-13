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
    "nocrypto"

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
    "irmin-graphql"
    "irmin-mirage-graphql"

    # broken since 4.12
    "ocaml_extlib-1-7-7"

    # doesn't work with my fork of http/af
    "paf"
    "paf-le"
    "paf-cohttp"
    "git-paf"
    "irmin-mirage-git"
    "git-mirage"
    "irmin-git"

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
    "batteries"
    "bonsai"
    "biocaml"
    "bls12-381-unix"
    "camlp5_strict"
    "camlp5"
    "cfstream"
    "cpdf"
    "csvfields"
    "dose3"
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
    "lablgtk3-gtkspell3"
    "lablgtk3-sourceview3"
    "lablgtk3"
    "lastfm"
    "memtrace_viewer"
    "ocaml_oasis"
    "ocaml-protoc"
    "ocaml-recovery-parser"
    "ocaml-sat-solvers"
    "ocamlify"
    "ocamlmod"
    "ocamlnet"
    "ocp-build"
    "owl-base"
    "owl"
    "parmap"
    "pgocaml"
    "pgocaml_ppx"
    "phylogenetics"
    "piqi"
    "piqi-ocaml"
    "ppx_python"
    "pyml"
    "redis-lwt"
    "redis-sync"
    "redis"
    "rfc7748"
    "ringo-lwt"
    "ringo_old"
    "session-redis-lwt"
    "sexp"
    "stdcompat"
    "telegraml"
    "twt"
    "uecc"
    "virtual_dom"
    "wodan-unix"
    "xenstore-tool"
    "xml-light"
    "labltk"

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
      ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";

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
    }); ({
      # just build a subset of the static overlay, with the most commonly used
      # packages
      inherit piaf-lwt caqti-driver-postgresql ppx_deriving;
    } // (if ocamlVersion == "5_00" then {
      inherit piaf carl;
      static-carl = carl.override { static = true; };
    } else { }));

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
