{ ocamlVersion, target ? "native" }:
let
  pkgs = import ./boot.nix { };
  inherit (pkgs) lib stdenv;
  ignoredPackages = [
    # camlp4 or not supported in 4.11+
    "bap"
    "camlp4"
    "camomile_0_8_2"
    "cil"
    "dypgen"
    "earlybird"
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
    "lwt-exit"
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
    "hacl-star-raw"
    "hacl-star"
    "ocaml_libvirt"
    "cairo2"
    "lablgtk3"
    "lablgtk3-gtkspell3"
    "lablgtk3-sourceview3"
    "labltk"
    "camlimages"
    "apron"
    "bjack"

    # broken with ppxlib 0.23
    "elpi"

    # broken on OCaml 4.13
    "hol_light"
    "ppx_tools_versioned"
    "ocaml-migrate-parsetree-1-8"
    "ocaml-migrate-parsetree"
    "wasm"
    "pythonlib"

    # Broken / EOL
    "morph"
    "morph_graphql_server"

    # Broken on OCaml 5.00
    "fontconfig"
    "cpdf"
    "merlin"
    "erm_xml"
    "functory"
    "getopt"
    "benchmark"

    # Incompatible with 4.14
    "pcap-format"
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
    "incr_dom"
    "bonsai"

    # https://github.com/mirage/metrics/issues/57
    "metrics-unix"
    "metrics-mirage"

    "dream-livereload"
    "dream-serve"

    # incompatible with cmdliner 1.1
    "git-unix"
    "git-cohttp"
    "git-cohttp-unix"

    # maybe nix-build-uncached bug? X requires non-existent output 'out' from Y
    "elina"
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
        lib.isDerivation v &&
        (! broken) &&
        (
          let platforms = (if ((v ? meta) && v.meta ? platforms) then v.meta.platforms else lib.platforms.all);
          in
          (builtins.elem stdenv.system platforms)
        ))
      ocamlPackages;

  crossTarget = pkgs:
    with (buildCandidates pkgs);
    [
      # just build a subset of the static overlay, with the most commonly used
      # packages
      piaf
      carl
      (carl.override { static = true; })
      caqti-driver-postgresql
      ppx_deriving
    ];

in

with pkgs;

{
  native =
    lib.attrValues (buildCandidates pkgs)
    ++ [
      # cockroachdb-21_1_x cockroachdb-21_2_x
      cockroachdb-22_x
      # mongodb-4_2
      # nixUnstable
      esy
    ]
    ++ lib.optional stdenv.isLinux [ kubernetes ];


  musl = crossTarget pkgs.pkgsCross.musl64;

  arm64 = crossTarget pkgs.pkgsCross.aarch64-multiplatform-musl;

}."${target}"
