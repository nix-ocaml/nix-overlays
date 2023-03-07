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
    "camlimages_4_2_4"
    "lablgtk-extras"
    "mezzo"
    "ocaml_cairo"
    "ocaml_cryptgps"
    "ocamlnat"
    "ocamlsdl"
    "lwt_camlp4"
    "macaque"
    "config-file"
    "erm_xmpp"
    "gmetadom"
    "stog"
    "ulex"
    "lablgl"

    # too long to build or broken
    "z3"
    "ocaml-r"

    # Only available for 4.14
    "melange-compiler-libs"
    "melange"
    "mel"

    # dune.configurator issue
    "ocamlfuse"
    "google-drive-ocamlfuse"

    # jbuild files
    "ocsigen-start"
    "torch"

    # linking issues?
    "spacetime_lib"
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

    # broken since OCaml 4.13
    "hol_light"
    "ppx_tools_versioned"
    "ocaml-migrate-parsetree-1-8"
    "ocaml-migrate-parsetree"
    "wasm"

    # Broken since OCaml 4.14
    "eliom"
    "ocsigen-toolkit"

    "dream-serve"

    # maybe nix-build-uncached bug? X requires non-existent output 'out' from Y
    "elina"

    "gd4o"

    "ocaml-sat-solvers"

    "ocaml-freestanding"

    "taglib"
    "getopt"
    "soundtouch"

    "inotify"
    "async_inotify"
    "async_smtp"
    "pgsolver"
    "tcslib"
    "plotkicadsch"

    # Not compatible with EIO yet
    "oidc-client"
  ];

  ocaml5Ignores = [
    "cpdf"
    "erm_xml"
    "fontconfig"
    "functory"
    "gapi-ocaml"
    "gsl"
    "hack_parallel"
    "inifiles"
    "lastfm"
    "ocaml_oasis"
    "ocaml-recovery-parser"
    "ocamlify"
    "ocamlmod"
    "ocamlnet"
    "ocp-build"
    "owl"
    "phylogenetics"
    "piqi"
    "piqi-ocaml"
    "ringo-lwt"
    "ringo_old"
    "semver"
    "twt"
    "lambdapi"
  ];

  darwinIgnores = [
    "dssi"

    # broken on macOS?
    "llvm"

    "alsa"
    "mm"
    "owl"

    "uring"
    "eio_linux"
  ];

  lowerThanOCaml5Ignores = [
    "lockfree"
    "domainslib"
    "dscheck"
    "cpdf"
  ];

in

rec {
  inherit ocaml5Ignores darwinIgnores lowerThanOCaml5Ignores;
  ocamlCandidates =
    { pkgs
    , ocamlVersion
    , disable_eio_linux ? false
    , extraIgnores ? if lib.hasPrefix "5_" ocamlVersion
      then ocaml5Ignores
      else lowerThanOCaml5Ignores
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
      inherit
        caqti-driver-postgresql ppx_deriving
        base cohttp-lwt-unix tls core core_unix utop irmin
        mirage-crypto-rng-async;
    } // (if ocamlVersion == "5_0" then {
      inherit piaf carl;
      static-carl = carl.override { static = true; };
    } else { }));

  crossTargetList = pkgs: ocamlVersion:
    let attrs = crossTarget pkgs ocamlVersion; in
    lib.attrValues attrs;
}
