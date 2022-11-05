{ nixpkgs
, autoconf
, automake
, buildPackages
, fetchpatch
, fetchFromGitHub
, lib
, libpq
, libev-oc
, libffi-oc
, makeWrapper
, darwin
, stdenv
, super-opaline
, gmp-oc
, openssl-oc
, pkg-config
, python3
, lmdb
, curl
, writeScriptBin
, libsodium
, cairo
, gtk2
, zlib-oc
}:

oself: osuper:

let
  nativeCairo = cairo;
  lmdb-pkg = lmdb;
  pkg-config-script =
    let
      pkg-config-pkg =
        if stdenv.cc.targetPrefix == ""
        then "${pkg-config}/bin/pkg-config"
        else "${stdenv.cc.targetPrefix}pkg-config";
    in
    writeScriptBin "pkg-config" ''
      #!${stdenv.shell}
      ${pkg-config-pkg} $@
    '';

  disableTests = d: d.overrideAttrs (_: { doCheck = false; });
  addBase = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.base ];
  });
  addStdio = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.stdio ];
  });
in

with oself;

{
  ansiterminal = disableTests osuper.ansiterminal;

  apron = osuper.apron.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace mlapronidl/scalar.idl --replace "Pervasives." "Stdlib."
      substituteInPlace mlapronidl/scalar.idl --replace " alloc_small" " caml_alloc_small"
      substituteInPlace mlapronidl/linexpr0.idl --replace " callback2" " caml_callback2"
      substituteInPlace mlapronidl/manager.idl --replace " invalid_argument" " caml_invalid_argument"
      substituteInPlace mlapronidl/apron_caml.c --replace "alloc_custom" "caml_alloc_custom"
      substituteInPlace mlapronidl/apron_caml.c --replace "serialize_int_8" "caml_serialize_int_8"
      substituteInPlace mlapronidl/apron_caml.c --replace "deserialize_uint_8" "caml_deserialize_uint_8"
      substituteInPlace mlapronidl/apron_caml.c --replace " serialize_block_1" " caml_serialize_block_1"
      substituteInPlace mlapronidl/apron_caml.c --replace "deserialize_block_1" "caml_deserialize_block_1"
      substituteInPlace mlapronidl/apron_caml.h --replace "alloc_custom" "caml_alloc_custom"
      substituteInPlace mlapronidl/apron_caml.c --replace " alloc_small" " caml_alloc_small"
      substituteInPlace mlapronidl/apron_caml.c --replace "register_custom_operations" "caml_register_custom_operations"
    '';
  });

  arp = osuper.arp.overrideAttrs (_: {
    buildInputs = if stdenv.isDarwin then [ ethernet ] else [ ];
    doCheck = ! stdenv.isDarwin;
  });

  archi = callPackage ./archi { };
  archi-lwt = callPackage ./archi/lwt.nix { };
  archi-async = callPackage ./archi/async.nix { };

  multiformats = buildDunePackage {
    pname = "multiformats";
    version = "dev";
    src = builtins.fetchurl {
      url = https://github.com/crackcomm/ocaml-multiformats/archive/380208ded45bc33cfadc5de6709846b3a8b84615.tar.gz;
      sha256 = "00qx8n16rxwjs1fs8z86f7byzradf38n2msxdj8p83n87vpcmm7f";
    };
    propagatedBuildInputs = [ ppx_jane ppx_deriving core_kernel stdint digestif ];
  };

  base32 = buildDunePackage {
    pname = "base32";
    version = "dev";
    src = builtins.fetchurl {
      url = https://gitlab.com/public.dream/dromedar/ocaml-base32/-/archive/main/ocaml-base32-main.tar.gz;
      sha256 = "0babid89q3vpgvq10cw233k9xzblsk89vh02ymviblgfjhm92lk5";
    };
  };

  base64 = osuper.base64.overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.0" then
        fetchFromGitHub
          {
            owner = "kit-ty-kate";
            repo = "ocaml-base64";
            rev = "749313a98dd2a7c0082aeffeeff038e800a573dc";
            sha256 = "sha256-mbd/wTJi40/WsyyezQAX0iwA1qKwPpP9XR/F7925ASM=";
          }
      else o.src;
  });

  batteries = osuper.batteries.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-batteries-team/batteries-included/archive/892b781966.tar.gz;
      sha256 = "073gmp7m61isq759ikl8yzk8mcfb5jc41fgl76m6gxyy88zh8d4y";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
    doCheck = false;
  });

  benchmark = osuper.buildDunePackage {
    pname = "benchmark";
    version = "1.6";

    src = fetchFromGitHub {
      owner = "Chris00";
      repo = "ocaml-benchmark";
      rev = "1.6";
      sha256 = "sha256-10KoyCLzY+uv0lCVrXD6YccLFmoknDa58cF9+aRrGzQ=";
    };
  };

  bigarray-compat = osuper.bigarray-compat.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/bigarray-compat/releases/download/v1.1.0/bigarray-compat-1.1.0.tbz;
      sha256 = "1m8q6ywik6h0wrdgv8ah2s617y37n1gdj4qvc86yi12winj6ji23";
    };

  });

  bigstring = osuper.bigstring.overrideAttrs (_: {
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace src/dune --replace " bigarray" "" --replace " bytes" ""
      '' else "";
  });

  bigstringaf = osuper.bigstringaf.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });

  biniou = osuper.biniou.overrideAttrs (o: {
    patches = [
      (fetchpatch {
        url = https://raw.githubusercontent.com/ocaml-bench/sandmark/2c5102156afd81cb4c0c91ab77375d5fc5d332bf/dependencies/packages/biniou/biniou.1.2.1/files/biniou-use-camlp-streams.patch;
        sha256 = "sha256-xwB+zpV1xZQyQgyF+NS+B/doxTZyE7vitXb+iN3sBbg=";
      })
    ];
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  bisect_ppx = osuper.bisect_ppx.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ ppxlib cmdliner ];
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/bisect_ppx/archive/cc442a08.tar.gz;
      sha256 = "08mx270xp1ypqvy9cfpyyvws538a0l90xasvbx0vs8071vgb2wri";
    };
  });

  bjack = osuper.bjack.overrideAttrs (o: {
    propagatedBuildInputs =
      o.propagatedBuildInputs
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        Accelerate
        CoreAudio
      ]);
  });

  bls12-381 = disableTests osuper.bls12-381;

  bls12-381-legacy = osuper.bls12-381-legacy.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./src/legacy/dune --replace "libraries " "libraries ctypes.stubs "
    '';
  });

  bos = osuper.bos.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/bos/archive/refs/tags/v0.2.1.tar.gz;
      sha256 = "18h2zipv6zqvrax2aia6hljnsgqni971119izskrajwkha3myj6d";
    };
  });

  bz2 = osuper.bz2.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace bz2.ml --replace "Pervasives" "Stdlib"
      substituteInPlace bz2.mli --replace "Pervasives" "Stdlib"
    '';
  });

  camlimages = osuper.camlimages.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ findlib ];
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace core/images.ml --replace "String.lowercase" "String.lowercase_ascii"
        substituteInPlace core/units.ml --replace "String.lowercase" "String.lowercase_ascii"
      '' else "";
  });

  camlp5 = callPackage ./camlp5 { };

  camlzip = osuper.camlzip.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/xavierleroy/camlzip/archive/3b0e0a5f7.tar.gz;
      sha256 = "00vkm3ix6fhdh0yx6zmvnnksgn0mpj5a0kz5ll9kdpdk6ysxvapz";
    };
    propagatedBuildInputs = [ zlib-oc ];
  });

  camomile = osuper.camomile.overrideAttrs (_: {
    patches = [ ./camomile.patch ];
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace Camomile/dune --replace " bigarray" ""
        substituteInPlace Camomile/toolslib/dune --replace " bigarray" ""
      '' else "";
    propagatedBuildInputs = [ camlp-streams ];
    postInstall = null;
  });

  cfstream = osuper.cfstream.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace lib/dune --replace \
        "libraries core_kernel" "libraries camlp-streams core_kernel"
      substituteInPlace app/cfstream_test.ml --replace \
        "Pervasives." "Stdlib."
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  checkseum = osuper.checkseum.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script ];
  });

  coin = osuper.coin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/coin/releases/download/v0.1.4/coin-0.1.4.tbz;
      sha256 = "0069qqswd1ik5ay3d5q1v1pz0ql31kblfsnv0ax0z8jwvacp3ack";
    };
  });

  calendar = callPackage ./calendar { };

  cairo2 = osuper.cairo2.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bigarray" ""
    '';
  });

  cairo2-gtk = buildDunePackage {
    pname = "cairo2-gtk";
    inherit (cairo2) version src;
    nativeBuildInputs = [ nativeCairo gtk2.dev pkg-config ];
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ cairo2 lablgtk ];
  };

  camlidl = callPackage ./camlidl { };

  cpdf = osuper.cpdf.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/johnwhitington/cpdf-source/archive/a0e93444b.tar.gz;
      sha256 = "10bl1x8shssx4fxiimg46js363dnlfms70k8x6jgn4fifa0vilzg";
    };
  });

  camlpdf = osuper.camlpdf.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/johnwhitington/camlpdf/archive/563afd602.tar.gz;
      sha256 = "0i52hr1zbdzpcn6hfylg748csaxcnaqi43amk315raxhsxirfc9k";
    };
  });

  carton = osuper.carton.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-git/releases/download/carton-v0.6.0/git-carton-v0.6.0.tbz;
      sha256 = "0mbz90lrsvqw17dx5mw33qcki8z76ya2j75zkqr3il6bmrgbh29l";
    };
    doCheck = false;
  });

  clz = buildDunePackage {
    pname = "clz";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://github.com/mseri/ocaml-clz/releases/download/0.1.0/clz-0.1.0.tbz;
      sha256 = "08n6qf5g470qx8xhvaizd061qcb3bndvb3c8b9p8cg98n3jpms4q";
    };
    propagatedBuildInputs = [
      ptime
      decompress
      bigstringaf
      lwt
      cohttp-lwt
    ];
  };

  cohttp = osuper.cohttp.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./cohttp/src/dune --replace "bytes" ""
    '';
  });

  conan = callPackage ./conan { };
  conan-lwt = callPackage ./conan/lwt.nix { };
  conan-unix = callPackage ./conan/unix.nix { };
  conan-database = callPackage ./conan/database.nix { };
  conan-cli = callPackage ./conan/cli.nix { };

  cookie = callPackage ./cookie { };
  session-cookie = callPackage ./cookie/session.nix { };
  session-cookie-lwt = callPackage ./cookie/session-lwt.nix { };

  # Not available for 4.12 and breaking the static build
  cooltt = null;

  cstruct-sexp = osuper.cstruct-sexp.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib_test/dune --replace "bigarray" ""
    '';
  });

  cstruct-unix = osuper.cstruct-unix.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./unix/dune --replace "bigarray" ""
    '';
  });

  ctypes = buildDunePackage rec {
    pname = "ctypes";
    version = "0.20.1";
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/64b6494d0.tar.gz;
      sha256 = "1xw13y93ncsfw5sz2y3vvbijl378xszavq1j08lznawy4rqf76bw";
    };

    nativeBuildInputs = [ pkg-config pkg-config-script ];
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ integers bigarray-compat libffi-oc.dev ];

    postPatch = ''
      substituteInPlace src/ctypes/dune --replace "libraries bytes" "libraries"
    '';
    postInstall = ''
      echo -e '\nversion = "${version}"'>> $out/lib/ocaml/${osuper.ocaml.version}/site-lib/ctypes/META
    '';
  };

  ctypes-foreign = buildDunePackage {
    pname = "ctypes-foreign";
    inherit (ctypes) src version;
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ ctypes ];
  };

  ctypes_stubs_js = osuper.ctypes_stubs_js.overrideAttrs (_: {
    doCheck = false;
  });

  cudf = buildDunePackage {
    pname = "cudf";
    version = "0.5.97+500";
    src = builtins.fetchurl {
      url = https://gitlab.com/irill/cudf/-/archive/419631fac6dac1eaa68abe15152fbba52100aa27.tar.gz;
      sha256 = "0yiisyl5a6la9mlhplfyjxl21ccwv6axjbb1v76xm69324z2xf9g";
    };

    propagatedBuildInputs = [ ocaml_extlib ];

    postPatch = ''
      substituteInPlace ./cudf.ml --replace "Pervasives." "Stdlib."
      substituteInPlace ./cudf_types_pp.ml --replace "Pervasives." "Stdlib."
    '';
  };

  crowbar = osuper.crowbar.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "stedolan";
      repo = "crowbar";
      rev = "0cbe3ea7e990a7d233360e6a74b1cb5e712501ad";
      sha256 = "+92SFFI24HEZe2By990wQKGaR6McggSR711tQHTpiis=";
    };

    doCheck = lib.versionAtLeast ocaml.version "5.0";
  });

  data-encoding = disableTests osuper.data-encoding;

  dataloader = callPackage ./dataloader { };
  dataloader-lwt = callPackage ./dataloader/lwt.nix { };

  decimal = callPackage ./decimal { };

  decoders = buildDunePackage {
    pname = "decoders";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/mattjbray/ocaml-decoders/archive/00d930.tar.gz;
      sha256 = "0ihl5gxv798bpsf861j0ckd7qq4x0i708ydi3i34q3z28lsrfg85";
    };
  };
  decoders-yojson = buildDunePackage {
    pname = "decoders-yojson";
    inherit (oself.decoders) src version;
    propagatedBuildInputs = [ decoders yojson ];
  };

  dolog = buildDunePackage {
    pname = "dolog";
    version = "6.0.0";
    src = builtins.fetchurl {
      url = https://github.com/UnixJunkie/dolog/archive/refs/tags/v6.0.0.tar.gz;
      sha256 = "0idxs1lnpsh49hvxnrkb3ijybd83phzbxfcichchw511k9ismlia";
    };
  };

  dream-pure = callPackage ./dream/pure.nix { };
  dream-httpaf = callPackage ./dream/httpaf.nix { };
  dream = callPackage ./dream { };

  dream-livereload = callPackage ./dream-livereload { };

  dream-serve = callPackage ./dream-serve { };

  dum = osuper.dum.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "dum.ml" --replace "Lazy.lazy_is_val" "Lazy.is_val"
      substituteInPlace "dum.ml" --replace "Obj.final_tag" "Obj.custom_tag"
    '';
  });

  # Make `dune` effectively be Dune v2.  This works because Dune 2 is
  # backwards compatible.

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

  dune_2 = dune_3;

  dune_3 = osuper.dune_3.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/dune/releases/download/3.5.0/dune-3.5.0.tbz;
      sha256 = "041n16sn41wwj6fgi7l10hvbl5x5swygqv33d4csx7rm0iklrgbp";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ makeWrapper ];

    postPatch = ''
      substituteInPlace "src/dune_rules/artifact_substitution.ml" --replace \
        '"-";' '"-"; "-f"; '
    '';

    postFixup =
      if stdenv.isDarwin then ''
        wrapProgram $out/bin/dune \
          --suffix PATH : "${darwin.sigtool}/bin"
      '' else "";
  });

  dune-configurator = callPackage ./dune/configurator.nix { };
  dune-rpc = osuper.dune-rpc.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ stdune ordering pp xdg dyn ];
    inherit (dyn) preBuild;
  });
  dune-rpc-lwt = callPackage ./dune/rpc-lwt.nix { };
  dyn = osuper.dyn.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    preBuild = ''
      rm -r vendor/csexp vendor/pp
    '';
  });
  dune-action-plugin = osuper.dune-action-plugin.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp dune-rpc ];
    inherit (dyn) preBuild;
  });
  dune-glob = osuper.dune-glob.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  dune-private-libs = osuper.dune-private-libs.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  dune-site = osuper.dune-site.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  fiber = osuper.fiber.overrideAttrs (o: {
    propagatedBuildInputs = [ pp ];
    inherit (dyn) preBuild;
  });
  stdune = osuper.stdune.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });

  dune-release = osuper.dune-release.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/dune-release/archive/ab37686.tar.gz;
      sha256 = "11m2zxra43ag2xsmc6mnaq36hnq3g2kql15d6dik4hw0jq7f2dz8";
    };
    doCheck = false;
  });

  ezgzip = buildDunePackage rec {
    pname = "ezgzip";
    version = "0.2.3";
    src = builtins.fetchurl {
      url = "https://github.com/hcarty/${pname}/archive/v${version}.tar.gz";
      sha256 = "0zjss0hljpy3mxpi1ccdvicb4j0qg5dl6549i23smy1x07pr0nmr";
    };
    propagatedBuildInputs = [ rresult astring ocplib-endian camlzip result ];
  };

  facile = osuper.facile.overrideAttrs (_: {
    postPatch = "echo '(lang dune 2.0)' > dune-project";
  });

  faraday-async = osuper.faraday-async.overrideAttrs (_: {
    patches = [ ];
  });

  findlib = osuper.findlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/ocamlfind/archive/refs/tags/findlib-1.9.6.tar.gz;
      sha256 = "063i6s3cqmrwhd8ncgvkl856vqsa6ckcvlmif59ifczsqy21iwfa";
    };
    patches = [
      "${nixpkgs}/pkgs/development/tools/ocaml/findlib/ldconf.patch"
      ./findlib_install_topfind.patch
    ];
  });

  fix = osuper.fix.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/fix/-/archive/20220121/archive.tar.gz;
      sha256 = "1bd8xnk3qf7nfsmk3z6hksvcascndbl7pp2a50ndj8hzf7hdnfwm";
    };
  });

  ff-pbt = osuper.ff-pbt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ alcotest ];
  });

  flow_parser = callPackage ./flow_parser { };

  fmt = osuper.fmt.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://erratique.ch/software/fmt/releases/fmt-0.9.0.tbz;
      sha256 = "0q8j2in2473xh7k4hfgnppv9qy77f2ih89yp6yhpbp92ba021yzi";
    };
    propagatedBuildInputs = [ cmdliner ];
  });

  fileutils = osuper.fileutils.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/gildor478/ocaml-fileutils/releases/download/v0.6.4/fileutils-0.6.4.tbz;
      sha256 = "0ps41axgp8b83mgplhfllb2ndlqhkfg6mr5lqbdfpdindaybcyvs";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ seq ];
  });

  gen = buildDunePackage {
    pname = "gen";
    version = "v1.0";
    src = fetchFromGitHub {
      owner = "c-cube";
      repo = "gen";
      rev = "v1.0";
      sha256 = "1z5nw5wljvcqp8q07h336bbvf9paynia0jsdh4486hlkbmr1ask1";
    };
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ seq ];
    postPatch = ''
      substituteInPlace ./src/dune --replace "bytes seq" "seq"
    '';
  };

  gen_js_api = disableTests osuper.gen_js_api;

  gettext-stub = disableTests osuper.gettext-stub;

  gluten = callPackage ./gluten { };
  gluten-lwt = callPackage ./gluten/lwt.nix { };
  gluten-lwt-unix = callPackage ./gluten/lwt-unix.nix { };
  gluten-mirage = callPackage ./gluten/mirage.nix { };
  gluten-async = callPackage ./gluten/async.nix { };

  graphql_parser = callPackage ./graphql/parser.nix { };
  graphql = callPackage ./graphql { };
  graphql-lwt = callPackage ./graphql/lwt.nix { };
  graphql-async = callPackage ./graphql/async.nix { };

  graphql_ppx = callPackage ./graphql_ppx { };
  graphql-cohttp = osuper.graphql-cohttp.overrideAttrs (o: {
    # https://github.com/NixOS/nixpkgs/pull/170664
    nativeBuildInputs = [ ocaml dune findlib crunch ];
  });

  gsl = osuper.gsl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mmottl/gsl-ocaml/archive/76f8d93cc.tar.gz;
      sha256 = "0s1h7xrlmq8djaxywq48s1jm7x5f6j7mfkljjw8kk52dfjsfwxw0";
    };
    postPatch = ''
      substituteInPlace ./src/dune --replace "bigarray" ""
    '';
  });

  gstreamer = osuper.gstreamer.overrideAttrs (o: {
    propagatedBuildInputs =
      o.propagatedBuildInputs
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        AppKit
        Foundation
      ]);
  });

  hacl-star = osuper.hacl-star.overrideAttrs (_: {
    postPatch = ''
      ls -lah .
      substituteInPlace ./dune --replace "libraries " "libraries ctypes.stubs "
    '';
  });

  happy-eyeballs = osuper.happy-eyeballs.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/roburio/happy-eyeballs/releases/download/v0.3.0/happy-eyeballs-0.3.0.tbz;
      sha256 = "17mnid1gvq1ml1zmqzn0m6jmrqw4kqdrjqrdsrphl5kxxyhs03m6";
    };
  });

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  hpack = callPackage ./h2/hpack.nix { };

  hidapi = osuper.hidapi.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    postPatch = ''
      substituteInPlace ./src/hidapi_stubs.c --replace "alloc_custom" "caml_alloc_custom"
    '';
  });

  httpaf = callPackage ./httpaf { };
  httpaf-lwt = callPackage ./httpaf/lwt.nix { };
  httpaf-lwt-unix = callPackage ./httpaf/lwt-unix.nix { };
  httpaf-mirage = callPackage ./httpaf/mirage.nix { };
  httpaf-async = callPackage ./httpaf/async.nix { };

  hxd = osuper.hxd.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    doCheck = false;
  });

  hyper = callPackage ./hyper { };

  integers = osuper.integers.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/signed.ml --replace "Pervasives" "Stdlib"
      substituteInPlace ./src/unsigned.ml --replace "Pervasives" "Stdlib"
    '';
  });

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  irmin-fs = disableTests osuper.irmin-fs;
  irmin-chunk = disableTests osuper.irmin-chunk;
  irmin-pack = disableTests osuper.irmin-pack;
  irmin-git = disableTests osuper.irmin-git;
  irmin-http = disableTests osuper.irmin-http;
  irmin-tezos = disableTests osuper.irmin-tezos;
  # https://github.com/mirage/metrics/issues/57
  irmin-test = null;

  iter = osuper.iter.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/iter/archive/refs/tags/v1.6.tar.gz;
      sha256 = "0blvp84nhws2amyhh9pkm4qnzm3rw5ya73fh88312v5w0gh5i1xk";
    };

    postPatch = ''
      substituteInPlace src/dune --replace "(libraries bytes)" ""
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ seq ];
    # MDX has some broken python transitive deps
    doCheck = false;
  });
  qcheck-core = osuper.qcheck-core.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/core/dune --replace "unix bytes" "unix"
    '';
  });
  qcheck-ounit = osuper.qcheck-ounit.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/ounit/dune --replace "unix bytes" "unix"
    '';
  });
  qtest = osuper.qtest.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace "bytes" ""
    '';
  });

  itv-tree = buildDunePackage {
    pname = "itv-tree";
    version = "2.1";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/interval-tree/archive/2fb2f2b.tar.gz;
      sha256 = "1gfb4dicqfs5cgyp03w39fm4x8yymxzajdzx1iybxg0c2ivax47c";
    };

    postPatch = ''
      substituteInPlace ./setup.ml --replace "Pervasives." "Stdlib."
    '';

    propagatedBuildInputs = [ camlp-streams ];
  };

  javalib = osuper.javalib.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/ptrees/ptset.ml --replace "Pervasives." "Stdlib."
      substituteInPlace ./src/jFile.ml --replace "Pervasives." "Stdlib."
    '';

  });

  jose = callPackage ./jose { };


  js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/js_of_ocaml/archive/22f219a55.tar.gz;
      sha256 = "1x7bzkl7nws32xcrp526j5mfsm5s9ivr8wl1kw5xwphv8p8c636m";
    };
  });
  js_of_ocaml-ocamlbuild = osuper.js_of_ocaml-ocamlbuild.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/js_of_ocaml-ocamlbuild/releases/download/5.0/js_of_ocaml-ocamlbuild-5.0.tbz;
      sha256 = "0yy0l6qfn76ak2hy6h7jw3drszpi3wn8lymp7qmcnyz23jzvqnda";
    };
  });

  jsonm = osuper.jsonm.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/jsonm/archive/7220492e3909002935aa2851edab4ee4eadb324c.tar.gz;
      sha256 = "1fykr7ivn9jmf75f06dpnrvb7v44143wr0n0f6nxj45bxf0mchbd";
    };
  });

  kafka = osuper.kafka.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib/ocaml_kafka.c --replace "= alloc_small" "= caml_alloc_small"
    '';
  });

  ke = osuper.ke.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./lib/dune --replace "bigarray-compat" ""
    '';
  });

  lablgtk = osuper.lablgtk.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/garrigue/lablgtk/archive/78fcdd2.tar.gz;
      sha256 = "0b7pz1391m9x03r9f9yixzj09slnk02nixddpzb40vgpq3zizarr";
    };
    patches = [ ./lablgtk.patch ];
    propagatedBuildInputs = [ camlp-streams ];
  });

  lablgtk3 = osuper.lablgtk3.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/garrigue/lablgtk/releases/download/3.1.3/lablgtk3-3.1.3.tbz;
      sha256 = "1ii1018hli5r1f2jsw8xviyg8n5jnimsiv8mapw6w5nf2pxffskq";
    };
    postPatch = ''
      substituteInPlace dune-project --replace '(version 3.1.2)' ""
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  lacaml = osuper.lacaml.overrideAttrs (_: {
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace src/dune --replace " bigarray" ""
      '' else "";
  });

  lambda-term = osuper.lambda-term.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/lambda-term/releases/download/3.3.1/lambda-term-3.3.1.tbz;
      sha256 = "0g6vjl9qlggiskx2n78vhjgcha4h9vxmbyxighayjsnmjvhcnxsv";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ logs ];
  });

  lmdb = buildDunePackage {
    pname = "lmdb";
    version = "1.0";
    src = builtins.fetchurl {
      url = https://github.com/Drup/ocaml-lmdb/archive/1.0.tar.gz;
      sha256 = "0nkax7v4yggk21yxgvx3ax8fg74yl1bhj4z09szfblmsxsy5ydd4";
    };
    nativeBuildInputs = [ pkg-config-script pkg-config ];
    buildInputs = [ lmdb-pkg dune-configurator ];
    propagatedBuildInputs = [ bigstringaf ];
  };

  lilv = osuper.lilv.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "ctypes.foreign" "ctypes-foreign"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ctypes-foreign ];
  });

  lru = osuper.lru.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/pqwy/lru/releases/download/v0.3.1/lru-0.3.1.tbz;
      sha256 = "1z9nnba2b4q0q0syyqk4790hzxs71la8h2wwhr7j8nvxgb927gkc";
    };
  });

  lutils = buildDunePackage {
    pname = "lutils";
    version = "1.51.3";
    src = builtins.fetchurl {
      url = https://gricad-gitlab.univ-grenoble-alpes.fr/verimag/synchrone/lutils/-/archive/1.51.3/lutils-1.51.3.tar.gz;
      sha256 = "0brbv0hzddac8v9kfm97i81d0x9nnlfpmwgk0mzc2vpy3p3vd315";
    };
    propagatedBuildInputs = [ num camlp-streams ];

    postPatch = ''
      substituteInPlace lib/dune --replace "(libraries " "(libraries camlp-streams "
    '';
  };

  luv_unix = buildDunePackage {
    pname = "luv_unix";
    inherit (luv) version src;
    propagatedBuildInputs = [ luv ];
  };

  lwt = osuper.lwt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ bigarray-compat libev-oc ];
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config cppo ];

    postPatch = ''
      substituteInPlace src/core/dune --replace "(libraries bytes)" ""
      substituteInPlace src/unix/dune --replace "bigarray" ""
    '';
  });

  lwt_ssl = osuper.lwt_ssl.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/lwt_ssl/archive/e68d8aab.tar.gz;
      sha256 = "07b81nnni0isviqkyv3a4lvjfpgscnil3dk5xhfm5rlhqdqg5r1n";
    };
  });

  lwt-watcher = osuper.lwt-watcher.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/70f826c503cc094ed2de3aa81fa385ea9fddb903.tar.gz;
      sha256 = "0q1qdmagldhwrcqiinsfag6zxcn5wbvn2p10wpyi8rgk27q3l8sk";
    };
  });

  lwt_react = callPackage ./lwt/react.nix { };

  magic-mime = osuper.magic-mime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-magic-mime/releases/download/v1.3.0/magic-mime-1.3.0.tbz;
      sha256 = "176dywi6d1s1jn1g1c8f9bznj1r6ajgqp5g196fgszld52598dfq";
    };
  });
  mdx = osuper.mdx.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/realworldocaml/mdx/archive/b8b779c0.tar.gz;
      sha256 = "045mqx45r71f7zmgdl7ri0g3f6p4hzjs5l3garvwxg6921702j6n";
    };
  });

  mirage-crypto = osuper.mirage-crypto.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage-crypto/releases/download/v0.10.7/mirage-crypto-0.10.7.tbz;
      sha256 = "1756i2wnx0sga86nhnqhw02dv9yjrnql6svv9il5np131iv8m09y";
    };

    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
    buildInputs = [ dune-configurator ];
  });
  mirage-crypto-pk = osuper.mirage-crypto-pk.override { gmp = gmp-oc; };

  mustache = osuper.mustache.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/rgrinberg/ocaml-mustache/archive/d0c45499f9a5ee91c38cf605ae20ecee47142fd8.tar.gz;
      sha256 = "0dl7islmm9pdwmbkj9dfvbw16kvaxf47w34x38hgqlgvqyfdvcp8";
    };

    doCheck = false;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ cmdliner ];
    postPatch = ''
      rm -rf bin/dune
      rm -rf bin/mustache_cli.ml
    '';
  });

  lambda-runtime = callPackage ./lambda-runtime { };
  vercel = callPackage ./lambda-runtime/vercel.nix { };

  logs = (osuper.logs.override { jsooSupport = false; });

  logs-ppx = callPackage ./logs-ppx { };

  landmarks = callPackage ./landmarks { };
  landmarks-ppx = callPackage ./landmarks/ppx.nix { };

  melange = callPackage ./melange { };
  mel = callPackage ./melange/mel.nix { };
  melange-compiler-libs = callPackage ./melange/compiler-libs.nix { };

  merlin-lib =
    if lib.versionAtLeast ocaml.version "4.14" then
      callPackage ./merlin/lib.nix { }
    else null;
  dot-merlin-reader = callPackage ./merlin/dot-merlin.nix { };
  merlin = callPackage ./merlin { };

  metapp = buildDunePackage {
    pname = "metapp";
    version = "0.4.4";
    src = builtins.fetchurl {
      url = https://github.com/thierry-martinez/metapp/releases/download/v0.4.4/metapp.0.4.4.tar.gz;
      sha256 = "0iy2ab5j9v87anj8d3dimy2vzxghryv7cb81yavrwazmjb3j5vmx";
    };
    propagatedBuildInputs = [ ppxlib stdcompat ];
  };

  metrics = osuper.metrics.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/unix/dune --replace "mtime.clock.os" ""
    '';
  });

  mlgmpidl = osuper.mlgmpidl.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/nberth/mlgmpidl/archive/refs/tags/1.2.14.tar.gz;
      sha256 = "0y5qb73nbiz81bg599by695f5kvm0ax199jax7xygbx48s9pm2fr";
    };
    postPatch = ''
      substituteInPlace Makefile --replace " bigarray" ""
      substituteInPlace Makefile --replace "$(OCAMLOPT) -p " "$(OCAMLOPT) "
      substituteInPlace gmp_caml.c --replace "alloc_custom" "caml_alloc_custom"
    '';
  });

  mongo = callPackage ./mongo { };
  mongo-lwt = callPackage ./mongo/lwt.nix { };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { };
  bson = callPackage ./mongo/bson.nix { };

  mimic = osuper.mimic.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dinosaure/mimic/releases/download/0.0.5/mimic-0.0.5.tbz;
      sha256 = "1b9x2rwc0ag32lfkqqygq42rbdngfjgdgyya7a3p50absnv678fy";
    };
  });
  mimic-happy-eyeballs = buildDunePackage {
    pname = "mimic-happy-eyeballs";
    inherit (mimic) version src;
    propagatedBuildInputs = [ mimic happy-eyeballs-mirage ];
  };

  mrmime = osuper.mrmime.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];

    # https://github.com/mirage/mrmime/issues/91
    doCheck = !lib.versionAtLeast ocaml.version "5.0";
  });

  mtime = (osuper.mtime.override { jsooSupport = false; }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/mtime/archive/refs/tags/v1.4.0.tar.gz;
      sha256 = "0r88q17ygsm3gq7hh89vzmq2ny3ha8im8sy5nn9xa4br9cz7khwx";
    };
    buildPhase = "${topkg.run} build";
  });

  multipart_form = callPackage ./multipart_form { };
  multipart_form-lwt = callPackage ./multipart_form/lwt.nix { };

  multipart-form-data = callPackage ./multipart-form-data { };

  mmap = osuper.mmap.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mmap/archive/41596aa.tar.gz;
      sha256 = "0fxv8qff9fsribymjgka7rq050i9yisph74nx642i5z7ng8ahlxq";
    };
  });

  npy = osuper.npy.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  nonstd = osuper.nonstd.overrideAttrs (_: {
    postPatch = "echo '(lang dune 2.0)' > dune-project";
  });

  num = osuper.num.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/num/archive/703e1f88.tar.gz;
      sha256 = "1b84kc4vfg4cipwwjav97pzbj7yk4ahpixj3ccbrnxhyazndyhqx";
    };

    patches = [ ./num/findlib-install.patch ];
  });

  ocaml = (osuper.ocaml.override { flambdaSupport = true; }).overrideAttrs (_: {
    enableParallelBuilding = true;
  });

  ocaml_extlib-1-7-8 = osuper.ocaml_extlib-1-7-8.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ygrek/ocaml-extlib/archive/9e9270de9d6c33e08a18096f7fb75b4205e6c1ed.tar.gz;
      sha256 = "006zc8jc1zx20iis06z3gppmikc6pfarx5ikdhihggk7k1wam6c1";
    };
  });

  # Tests don't work on 5.0 because of the Stream.t type.
  ocaml_gettext = disableTests osuper.ocaml_gettext;

  jsonrpc = osuper.jsonrpc.overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.0" then
        fetchFromGitHub
          {
            owner = "ocaml";
            repo = "ocaml-lsp";
            fetchSubmodules = true;
            rev = "63c12eb178471c7bd660460f489922377a3701d0";
            sha256 = "sha256-9WOieVlaojMuJTZLo0cCY5Qm1M0JX2asnlmwO6JbhJs=";
          }
      else o.src;
  });

  ocamlformat = callPackage ./ocamlformat { };

  inherit (callPackage ./ocamlformat-rpc { })
    # latest version
    ocamlformat-rpc
    ocamlformat-rpc_0_21_0;

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });

  ez_subst = buildDunePackage {
    pname = "ez_subst";
    version = "0.2.1";
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ez_subst/archive/refs/tags/v0.2.1.tar.gz;
      sha256 = "1mvrzd81paqcwqdm691n7izmaiw9s54as4a2h1wz4yvmai3sqmjx";
    };
  };

  ez_cmdliner = buildDunePackage {
    pname = "ez_cmdliner";
    version = "0.4.3";
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ez_cmdliner/archive/refs/tags/v0.4.3.tar.gz;
      sha256 = "07cnd1yw0pfzhjj6kdy040my3lmmma0r8v66wf4r3wibpw4a1am4";
    };
    propagatedBuildInputs = [ cmdliner ez_subst ocplib_stuff ];
  };

  ocaml-migrate-types = callPackage ./ocaml-migrate-types { };
  typedppxlib = callPackage ./typedppxlib { };
  ppx_debug = callPackage ./typedppxlib/ppx_debug.nix { };

  ocamlbuild = osuper.ocamlbuild.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ makeWrapper ];

    # OCamlbuild needs to find the native toolchain when cross compiling (to
    # link myocamlbuild programs)
    postFixup = ''
      wrapProgram $out/bin/ocamlbuild \
        --suffix PATH : "${ buildPackages.stdenv.cc }/bin"
    '';
  });

  ocaml-recovery-parser = osuper.ocaml-recovery-parser.overrideAttrs (o: rec {
    postPatch = ''
      substituteInPlace "menhir-recover/emitter.ml" --replace \
        "String.capitalize" "String.capitalize_ascii"
    '';
  });

  ocplib_stuff = buildDunePackage {
    pname = "ocplib_stuff";
    version = "0.3.0";
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocplib_stuff/archive/refs/tags/v0.3.0.tar.gz;
      sha256 = "0r5xh2aj1mbmj6ncxzkjzadgz42gw4x0qxxqdcm2m6531pcyfpq5";
    };
  };

  ocp-indent = osuper.ocp-indent.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "libraries bytes" "libraries "
    '';
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ocplib-endian = osuper.ocplib-endian.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocamlpro/ocplib-endian/archive/4a9fd796.tar.gz;
      sha256 = "1ic1dwzp7bi7kdkbbzd7h38dvzhw83xzja7mzam6nsvnax4xp0sa";
    };
    propagatedBuildInputs = [ bigarray-compat ];
  });

  ocplib-json-typed = osuper.ocplib-json-typed.overrideAttrs (o: {
    preConfigure = "echo '(lang dune 2.0)' > dune-project";
  });
  ocplib-json-typed-browser = osuper.ocplib-json-typed-browser.overrideAttrs (o: {
    preConfigure = "echo '(lang dune 2.0)' > dune-project";
  });
  ocplib-json-typed-bson = osuper.ocplib-json-typed-bson.overrideAttrs (o: {
    preConfigure = "echo '(lang dune 2.0)' > dune-project";
  });

  ocurl = stdenv.mkDerivation rec {
    name = "ocurl-0.9.1";
    src = builtins.fetchurl {
      url = "http://ygrek.org.ua/p/release/ocurl/${name}.tar.gz";
      sha256 = "0n621cxb9012pj280c7821qqsdhypj8qy9qgrah79dkh6a8h2py6";
    };

    nativeBuildInputs = [ pkg-config-script pkg-config ocaml findlib ];
    propagatedBuildInputs = [ curl lwt ];
    createFindlibDestdir = true;
  };

  oidc = callPackage ./oidc { };
  oidc-client = callPackage ./oidc/client.nix { };

  ocsigen-toolkit = osuper.ocsigen-toolkit.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/ocsigen-toolkit/archive/499e8260df6487ebdacb9fcccb2f9dec36df8063.tar.gz;
      sha256 = "10zlgp7wmrwwzq6298y7q4hlsmpq587vlcppj81hly3as1jq16ni";
    };
  });

  odoc = callPackage ./odoc { };

  omd = osuper.omd.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "bytes" ""
    '';
  });

  opam-core = osuper.opam-core.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/core/dune --replace "bigarray" ""
    '';
  });

  opaline = super-opaline.override { ocamlPackages = oself; };

  oseq = buildDunePackage {
    pname = "oseq";
    version = "0.4";
    src = builtins.fetchurl {
      url = https://github.com/c-cube/oseq/archive/refs/tags/v0.4.tar.gz;
      sha256 = "0bbn1swp92zh49pszxm34rnx0bfq1zwdjz50yy05nnchr5lva0jf";
    };
    propagatedBuildInputs = [ seq ];
  };

  otfm = osuper.otfm.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/otfm.ml --replace "Pervasives." "Stdlib."
    '';
  });

  owl = osuper.owl.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/base/dune --replace " bigarray" ""
    '';
  });

  ounit2 = osuper.ounit2.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/gildor478/ounit/releases/download/v2.2.6/ounit-2.2.6.tbz;
      sha256 = "04src5dc95bchimvnlbxih78pn95336b6rimbknqx8ch1qggp406";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ seq ];
    postPatch = ''
      substituteInPlace src/lib/ounit2/advanced/dune --replace " bytes " " "
    '';
  });

  parany = osuper.parany.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/UnixJunkie/parany/archive/refs/tags/v12.2.0.tar.gz;
      sha256 = "1k1xrx7zdgw72ahksdabd7wilds8hjngbc95q4l5wp05gqml6i4k";
    };
    propagatedBuildInputs = [ cpu ];
  });

  parmap = disableTests osuper.parmap;

  # These require crowbar which is still not compatible with newer cmdliner.
  pecu = disableTests osuper.pecu;

  pgocaml = osuper.pgocaml.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace \
        "(libraries calendar" \
        "(libraries camlp-streams calendar"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });
  pg_query = callPackage ./pg_query { };

  piaf-lwt = callPackage ./piaf/lwt.nix { };
  # Overridden for 5.0 in `./ocaml5.nix`;
  piaf = piaf-lwt;

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mmottl/postgresql-ocaml/archive/42c42e9cb.tar.gz;
      sha256 = "1fq7ihjdpy0m53m5njqbpvg2kwx0ax0yvncrwvm413gk3h7ph9py";
    };

    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
    nativeBuildInputs = o.nativeBuildInputs ++ [ libpq pkg-config-script pkg-config ];
  });

  pp = disableTests osuper.pp;

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ppx/dune --replace " bigarray" ""
    '';
    # To avoid bringing in OMP
    doCheck = false;
  });

  ppx_cstubs = osuper.ppx_cstubs.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  ppxlib = osuper.ppxlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.28.0/ppxlib-0.28.0.tbz;
      sha256 = "0xzk1jv4hm37p7l02j157plbibk61ashjj4nr8466841l3wyaynq";
    };
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving/archive/b4896214b0.tar.gz;
      sha256 = "0ppp0vki2qpcdnv79gklkmkkrzwmra5wba1sbms1m8ndji9p1bhh";
    };
    buildInputs = [ ];
    propagatedBuildInputs = [
      findlib
      ppxlib
      ppx_derivers
      result
    ];
  });

  ppx_deriving_cmdliner = osuper.ppx_deriving_cmdliner.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/hammerlab/ppx_deriving_cmdliner/archive/1f086651fe7f8dd98e371b09c6fcc4dbc6db1c7c.tar.gz;
      sha256 = "105y30gn6gp1hcwmx9g8vyki5hy5bi2jgbs0km5z1rq7i3kyb8kk";
    };
  });

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/releases/download/v3.7.0/ppx_deriving_yojson-3.7.0.tar.gz;
      sha256 = "1h7vz7lhvsgn6nl68g3dhhghlm884xpa1xawm6wm54pjc57gc6xx";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ppx_blob = disableTests osuper.ppx_blob;

  ppx_import = osuper.ppx_import.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_import/archive/c9df42cfaa35b9c3a5190d0c6afd8ea90a0017b1.tar.gz;
      sha256 = "00mhgzzkgggl0qyabhcpspsww9jn9adjj1r3w162vm2cysifaz2v";
    };
  });

  ppx_tools = callPackage ./ppx_tools { };

  printbox = disableTests osuper.printbox;
  printbox-text = osuper.printbox-text.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/printbox/archive/refs/tags/v0.6.tar.gz;
      sha256 = "1hr6g23b8z0p9kk1g996bzbrrziqk9b2c1za5xyzcq5g3xxqipij";
    };
    preBuild = "rm -rf ./dune";
    doCheck = false;
  });

  psq = osuper.psq.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/pqwy/psq/releases/download/v0.2.1/psq-0.2.1.tbz;
      sha256 = "0i6k5i3dha3b4syz4jpd5fi6dkalas8bhcpfk4blprxb7r9my022";
    };
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  reanalyze =
    if lib.versionOlder "4.13" osuper.ocaml.version then null
    else
      osuper.buildDunePackage {
        pname = "reanalyze";
        version = "2.17.0";
        src = builtins.fetchurl {
          url = https://github.com/rescript-association/reanalyze/archive/refs/tags/v2.17.0.tar.gz;
          sha256 = "0mdsawd08qkxw5cy3qfj49zims4cq3sh0kdlm43c7pshm930qbhj";
        };

        nativeBuildInputs = [ cppo ];
      };

  reason = callPackage ./reason { };
  rtop = callPackage ./reason/rtop.nix { };

  reason-native = osuper.reason-native.overrideScope' (rself: rsuper: {
    rely = rsuper.rely.overrideAttrs (_: {
      postPatch = ''
        substituteInPlace "src/rely/TestSuiteRunner.re" --replace "Pervasives." "Stdlib."
      '';
    });
    qcheck-rely = null;
  });

  react = osuper.react.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ topkg ];
  });

  reactivedata = osuper.reactivedata.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "src/reactiveData.ml" --replace "Pervasives." "Stdlib."
    '';
  });

  redemon = callPackage ./redemon { };
  redis = callPackage ./redis { };
  redis-lwt = callPackage ./redis/lwt.nix { };
  redis-sync = callPackage ./redis/sync.nix { };

  reenv = callPackage ./reenv { };

  rfc7748 = osuper.rfc7748.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "src/curve.ml" --replace "Pervasives." "Stdlib."
    '';
  });

  aches = buildDunePackage {
    pname = "aches";
    version = "1.0.0";
    inherit (ringo) src;
    propagatedBuildInputs = [ ringo ];
  };
  aches-lwt = buildDunePackage {
    pname = "aches-lwt";
    version = "1.0.0";
    inherit (ringo) src;
    propagatedBuildInputs = [ aches lwt ];
  };
  ringo_old = osuper.ringo;
  ringo-lwt = osuper.ringo-lwt.override { ringo = ringo_old; };

  ringo = osuper.ringo.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/ringo/-/archive/v1.0.0/ringo-v1.0.0.tar.gz;
      sha256 = "1wjzzxk1xldxn2pawhbjkmmgpzmsynqx5q03y0c8ll92vg8a7bp1";
    };
    checkInputs = [ lwt ];
  });

  rock = callPackage ./opium/rock.nix { };
  opium = callPackage ./opium { };

  rope = osuper.rope.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "src/dune" --replace "bytes" ""
      substituteInPlace "src/rope.ml" --replace "Pervasives" "Stdlib"
    '';
  });

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anuragsoni/routes/releases/download/2.0.0/routes-2.0.0.tbz;
      sha256 = "126nn0gbh12i7yf0qn01ryfp2qw0aj1xfk1vq42fa01biilrsqiv";
    };
  });

  # For ppx_css
  sedlex_2 = sedlex;
  sedlex = osuper.sedlex.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/sedlex/archive/refs/tags/v2.6.tar.gz;
      sha256 = "12n9ji158qcvmmh6334bvvmnraddcnp6kg6r41sn6gc55s85mxcv";
    };
    preBuild = ''
      substituteInPlace src/lib/dune --replace "(libraries " "(libraries camlp-streams "
    '';

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  sendfile = callPackage ./sendfile { };

  session = callPackage ./session { };
  session-redis-lwt = callPackage ./session/redis.nix { };

  sha = osuper.sha.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/djs55/ocaml-sha/releases/download/1.15.2/sha-1.15.2.tbz;
      sha256 = "1dzzhchknnbrpp5s81iqbvmqp4s0l75yrq8snj70ch3wkarmgg9z";
    };
  });

  sodium = buildDunePackage {
    pname = "sodium";
    version = "0.8+ahrefs";
    src = builtins.fetchurl {
      url = https://github.com/ahrefs/ocaml-sodium/archive/4c92a94a330f969bf4db7fb0ea07602d80c03b14.tar.gz;
      sha256 = "1dmddcg4v1g99cbgvkhdpz2c3xrdlmn3asvr5mhdjfggk5bbzw5f";
    };
    patches = [ ./sodium-cc-patch.patch ];
    postPatch = ''
      substituteInPlace lib_gen/dune --replace "ctypes)" "ctypes ctypes.stubs)"
      substituteInPlace lib_gen/dune --replace "ctypes s" "ctypes ctypes.stubs s"
      substituteInPlace lib_gen/dune --replace \
        "ocamlfind query ctypes ctypes.stubs" \
        "ocamlfind query ctypes"
    '';
    propagatedBuildInputs = [ ctypes libsodium ];
  };

  sosa = osuper.sosa.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/lib/functors.ml --replace "Pervasives" "Stdlib"
      substituteInPlace src/lib/list_of.ml --replace "Pervasives" "Stdlib"
      substituteInPlace src/lib/of_mutable.ml --replace "Pervasives" "Stdlib"
    '';
  });


  sourcemaps = buildDunePackage {
    pname = "sourcemaps";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/flow/ocaml-sourcemaps/archive/2bc7e6e.tar.gz;
      sha256 = "12ijyczailjd854x1796bwib52f7d87hsh8qkkgp4b9kcn6cbpdv";
    };
    propagatedBuildInputs = [ vlq ];
  };

  spelll = osuper.spelll.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/Spelll.ml --replace "Pervasives" "Stdlib"
    '';
  });

  ssl = osuper.ssl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/savonet/ocaml-ssl/archive/caf30cc.tar.gz;
      sha256 = "14bz4drfkyq9srsyswf5ka20n0xgr09s0dsnzrqdqv8f0671sibp";
    };
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl-oc.dev ];
  });

  stdcompat = osuper.stdcompat.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib autoconf automake ];
    src = builtins.fetchurl {
      url = https://github.com/thierry-martinez/stdcompat/releases/download/v19/stdcompat-19.tar.gz;
      sha256 = "0m8a6mbv3n5aaf69fdnq5gpdr6yq7z08afjv7s9dw877i5vhd90c";
    };
  });

  stdint = osuper.stdint.overrideAttrs (_: {
    patches = [ ];
    src = builtins.fetchurl {
      url = https://github.com/andrenth/ocaml-stdint/releases/download/0.7.1/stdint-0.7.1.tbz;
      sha256 = "1d4n6gbrkx6s6np8ix4qf6zzi8kbwmhjsyajpf1zs3jhkdjwm1rk";
    };
  });
  subscriptions-transport-ws = callPackage ./subscriptions-transport-ws { };

  syndic = buildDunePackage rec {
    pname = "syndic";
    version = "1.6.1";
    src = builtins.fetchurl {
      url = "https://github.com/Cumulus/${pname}/releases/download/v${version}/syndic-v${version}.tbz";
      sha256 = "1i43yqg0i304vpiy3sf6kvjpapkdm6spkf83mj9ql1d4f7jg6c58";
    };
    propagatedBuildInputs = [ xmlm uri ptime ];
  };

  tar = osuper.tar.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-tar/releases/download/v2.2.1/tar-2.2.1.tbz;
      sha256 = "0anm3zj4bbcw7qjr2ad9r3vc3mb5vy5jay5r79w56l3vp03j1kj3";
    };
    version = "2.2.0";
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ decompress ];
  });
  tar-mirage = buildDunePackage {
    pname = "tar-mirage";
    inherit (tar) version src;
    propagatedBuildInputs = [
      cstruct
      lwt
      mirage-block
      mirage-clock
      mirage-kv
      ptime
      tar
    ];
  };

  toml = osuper.toml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-toml/to.ml/archive/41172b739dff43424a12f7c1f0f64939e3660648.tar.gz;
      sha256 = "0ck5bqyly3hxdb0kqgkjjl531893r7m4bhk6i93bv1wq2y58igzq";
    };

    preConfigure = ''
      echo '(using menhir 2.1)' >> ./dune-project
    '';
    patches = [ ];
  });

  tezos-protocol-compiler = osuper.tezos-protocol-compiler.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ ocp-ocamlres ];
  });

  tezos-protocol-010-PtGRANAD = osuper.tezos-protocol-010-PtGRANAD.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
      substituteInPlace proto_010_PtGRANAD/lib_protocol/dune.inc \
        --replace "-w +a-4-6-7-9-16-29-32-40..42-44-45-48-60-67-68" "-w +a-4-6-7-9-16-29-32-40..42-44-45-48-60-67-68-58"
    '';
  });

  tezos-protocol-011-PtHangz2 = osuper.tezos-protocol-011-PtHangz2.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
      substituteInPlace proto_011_PtHangz2/lib_protocol/dune.inc --replace "-w +a-4-40..42-44-45-48" "-w +a-4-40..42-44-45-48-58"
    '';
  });

  tezos-011-PtHangz2-test-helpers = osuper.tezos-011-PtHangz2-test-helpers.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
    '';
  });

  tezos-protocol-011-PtHangz2-parameters = osuper.tezos-protocol-011-PtHangz2-parameters.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
    '';
  });

  tezos-protocol-plugin-011-PtHangz2 = osuper.tezos-protocol-plugin-011-PtHangz2.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
    '';
  });

  tezos-client-011-PtHangz2 = osuper.tezos-client-011-PtHangz2.overrideAttrs (_: {
    postPatch = ''
      echo "(lang dune 3.0)" > dune-project
    '';
  });

  timedesc = callPackage ./timere/timedesc.nix { };
  timedesc-json = callPackage ./timere/timedesc-json.nix { };
  timedesc-sexp = callPackage ./timere/timedesc-sexp.nix { };
  timedesc-tzdb = callPackage ./timere/timedesc-tzdb.nix { };
  timedesc-tzlocal = callPackage ./timere/timedesc-tzlocal.nix { };
  timere = callPackage ./timere/default.nix { };
  timere-parse = callPackage ./timere/parse.nix { };

  tls = osuper.tls.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirleft/ocaml-tls/releases/download/v0.15.5/tls-0.15.5.tbz;
      sha256 = "0ln4rj6qc94v2bp3s7166z804rbd3l6k7kijb1m60c1f9ifyxzyj";
    };
  });

  tyxml = osuper.tyxml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/tyxml/archive/c28e871df6db66a261ba541aa15caad314c78ddc.tar.gz;
      sha256 = "10vbg9qdmmb96vrpv65px2ipshckzn12k2z611261ii7ab2y4s2s";
    };
  });
  tyxml-jsx = callPackage ./tyxml/jsx.nix { };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { };

  unix-errno = osuper.unix-errno.overrideAttrs (_: {
    patches = [ ./unix-errno.patch ];
  });

  unstrctrd = disableTests osuper.unstrctrd;

  uring = callPackage ./uring { };

  utop = osuper.utop.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/utop/archive/bbd9a6ed45.tar.gz;
      sha256 = "00k4bi48hr1q5ida8ca48dpxj7qlax89446ir6qshwy51yjv00sx";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ findlib ];
  });

  uuidm = osuper.uuidm.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace pkg/META --replace "bytes" ""
    '';
  });

  uutf = osuper.uutf.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/uutf/archive/refs/tags/v1.0.3.tar.gz;
      sha256 = "1520njh9qaqflnj1xaawwhxdmn7r1p3wrh1j7w8y91g5y3zcp95z";
    };
  });

  vlq = osuper.vlq.overrideAttrs (_: {
    propagatedBuildInputs = [ camlp-streams ];
    postPatch = ''
      substituteInPlace "src/dune" --replace \
        '(public_name vlq))' '(libraries camlp-streams)(public_name vlq))'
    '';
  });

  websocketaf = callPackage ./websocketaf { };
  websocketaf-lwt = callPackage ./websocketaf/lwt.nix { };
  websocketaf-lwt-unix = callPackage ./websocketaf/lwt-unix.nix { };
  websocketaf-async = callPackage ./websocketaf/async.nix { };
  websocketaf-mirage = callPackage ./websocketaf/mirage.nix { };

  wodan-unix = osuper.wodan-unix.overrideAttrs (_: {
    prePatch = ''
      substituteInPlace src/wodan-unix/dune \
        --replace "nocrypto.lwt" "nocrypto nocrypto.lwt nocrypto.unix"
    '';
  });

  xenstore-tool = osuper.xenstore-tool.overrideAttrs (o: {
    propagatedBuildInputs = [ camlp-streams ];
    postPatch = ''
      substituteInPlace "cli/dune" --replace \
        "libraries lwt" "libraries camlp-streams lwt"
    '';
  });

  yuscii = disableTests osuper.yuscii;

  zarith = (osuper.zarith.override { gmp = gmp-oc; }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/Zarith/archive/64ba1c7.tar.gz;
      sha256 = "1a247jcb7s7zg8w6ipk30j4nz7kd57l5aaxygl6n74myb9qjr6b4";
    };
  });

  zed = osuper.zed.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/zed/releases/download/3.2.0/zed-3.2.0.tbz;
      sha256 = "0gji5rp44mqsld117n8g93cqg8302py1piqshmvg63268fylj8rl";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ uuseg uutf ];
  });

  zmq = callPackage ./zmq { };
  zmq-lwt = callPackage ./zmq/lwt.nix { };

  secp256k1-internal = osuper.secp256k1-internal.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/ocaml-secp256k1-internal/-/archive/0.3/ocaml-secp256k1-internal-0.3.tar.bz2;
      sha256 = "0qrscikxq2bp8xb0i4rjfhs6vf9sm2ajynylvmxw2c0gsxz1z76c";
    };
    version = "0.3.1";
    prePatch = ''
      substituteInPlace src/secp256k1_wrap.c \
        --replace "alloc_custom" "caml_alloc_custom"
    '';
  });

  lambdasoup = osuper.lambdasoup.overrideAttrs (o: {
    prePatch = ''
      substituteInPlace src/soup.ml --replace "lowercase " "lowercase_ascii "
    '';
    postPatch = ''
      substituteInPlace "src/dune" --replace "(libraries " "(libraries camlp-streams "
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  # Jane Street Libraries

  async_js = osuper.async_js.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/async_js/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "0lpakc704yrd6lcblzq3nxklmazxggcp82rr9cw7zd7d05q9nxf6";
    };
  });

  async_ssl = osuper.async_ssl.overrideAttrs (_: {
    propagatedBuildInputs = [ async ctypes openssl-oc.dev ctypes-foreign ];
    postPatch = ''
      substituteInPlace "bindings/dune" --replace "ctypes.foreign" "ctypes-foreign"
    '';
  });

  async_udp = osuper.janePackage {
    pname = "async_udp";
    version = "0.15.0";
    minimumOCamlVersion = "4.08";
    hash = "CJLKkjB9l7ERaJInhrTKrdK0eaeA0U3GxOZ+idqD5pY=";
    meta.description = "A grab-bag of performance-oriented, UDP-oriented network tools.";
    propagatedBuildInputs = [ async ppx_jane ];
  };

  bin_prot = osuper.bin_prot.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  binaryen = callPackage ./binaryen { };

  bonsai = osuper.bonsai.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/bonsai/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "1gvlxwxsc7j8sc3k4x1c07fdhibbhcgmcyb138gl4gq78r0p2jhc";
    };
    patches = [ ];

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ patdiff ];
  });

  pyml = buildDunePackage {
    pname = "pyml";
    version = "20220905";
    src = builtins.fetchurl {
      url = https://github.com/thierry-martinez/pyml/releases/download/20220905/pyml.20220905.tar.gz;
      sha256 = "1r81iy2fdsi1cmh7s31aac9ih3mn5d2vxwgdg9wxkidrc33a8i5x";
    };

    propagatedBuildInputs = [
      python3
      stdcompat
    ];

  };

  pythonlib = osuper.pythonlib.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/pythonlib/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "0h0475xfd66hn3spmnsn0fizixr48l0vgh4dinabbbxcia7vja7d";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_optcomp ];
    meta.broken = false;
    patches = [ ];
  });
  core_unix = osuper.core_unix.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/core_unix/archive/refs/tags/v0.15.2.tar.gz;
      sha256 = "0yznym5rr4f2z4swsjjlj84aql1yrkij7zdkh6h0z5h38sahwva8";
    };

    postPatch = ''
      ${o.postPatch}

      ${if stdenv.isDarwin then ''
        substituteInPlace "core_unix/src/core_unix_time_stubs.c" --replace \
        "int ret = clock_getcpuclockid(pid, &clock);" \
        "int ret = -1;"
      '' else ""}
    '';
  });

  memtrace = osuper.buildDunePackage {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/memtrace/archive/refs/tags/v0.2.3.tar.gz;
      sha256 = "087m1ng2ih2v9v0qh1aknkpispd030nrd5ngcqqbnpdyg2g3fizs";
    };
    pname = "memtrace";
    version = "0.1.2-dev";
  };

  memtrace_viewer = janePackage {
    pname = "memtrace_viewer";
    version = "0.15.0";
    hash = "1kl2kdajdqcsg4hp4vhgsklzdz7p4j3jcwfrdziwyg4h9vcacrby";
    nativeBuildInputs = [
      ocaml-embed-file
      js_of_ocaml
    ];
    propagatedBuildInputs = [
      ppx_pattern_bind
      async_js
      async_kernel
      async_rpc_kernel
      bonsai
      core_kernel
      ppx_jane
      async_rpc_websocket
      virtual_dom
      js_of_ocaml-ppx
      memtrace
      ocaml-embed-file
    ];
    meta = {
      description = "Memtrace Viewer";
      mainProgram = "memtrace-viewer";
    };
  };

  patdiff = janePackage {
    pname = "patdiff";
    hash = "0623a7n5r659rkxbp96g361mvxkcgc6x9lcbkm3glnppplk5kxr9";
    propagatedBuildInputs = [ core_unix patience_diff ocaml_pcre ];
    meta = {
      description = "File Diff using the Patience Diff algorithm";
    };
  };

  postgres_async = osuper.buildDunePackage {
    pname = "postgres_async";
    version = "0.15.0";
    src = builtins.fetchurl {
      url = https://github.com/janestreet/postgres_async/archive/refs/tags/v0.15.0.tar.gz;
      sha256 = "1gqq5fzs921kvchfyv95jz1rswdp624wjp350h659frwmgk33d8h";
    };
    propagatedBuildInputs = [ ppx_jane core core_kernel async ];
  };

  sexplib0 = osuper.sexplib0.overrideAttrs (o: {
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
        [
          (fetchpatch {
            url = https://github.com/janestreet/sexplib0/commit/5efaf01fa9b226f84490e3d480a9bebf0a1106bf.patch;
            sha256 = "sha256-s0Sw1sI3ei4d+kvNElvD6s3ammdJiqgJsizfF5QDf5A=";
          })
        ]
      else [ ];
  });
  sexplib = osuper.sexplib.overrideAttrs (_: {
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
        [
          (fetchpatch {
            url = https://github.com/janestreet/sexplib/commit/aac0c11905c5cfcc07941677167c63c20f9ceba8.patch;
            sha256 = "sha256-vQIssYnfvlfmOM6Ix+BIHLNYXbCX60Kgn7prQs0bP2o=";
          })
        ] else [ ];
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  base = osuper.base.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/base/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "050syrp6v00gn50d6xvwv6a36zsk4zmahymgllxpw9paf4qk0pkm";
    };
  });

  core = osuper.core.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/core/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "14f9vy2hfcvb5ixwwgnpdr6jdmbx29ig0cakli1gbwlp3pdbsyvg";
    };
  });

  csvfields = osuper.csvfields.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/csvfields/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "1iwgs3810k1gikrqk71y4xfnf5lhl8l0mxj6vqcbq33dmy2mq28p";
    };
  });

  jst-config = osuper.jst-config.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/jst-config/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "06xlyg0cyvv742haypdjbl82b5h5mla9hhcg3q67csq1nfxyalvh";
    };

    patches = [ ];
  });

  ppx_css = osuper.ppx_css.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_css/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "0k1j6h2pm46fpjikladzdpzafk66nnd4snnj8m9w5k6gwfrs88rg";
    };
  });
  ppx_disable_unused_warnings = addBase osuper.ppx_disable_unused_warnings;
  ppx_cold = addBase osuper.ppx_cold;
  ppx_enumerate = addBase osuper.ppx_enumerate;
  ppx_fixed_literal = addBase osuper.ppx_fixed_literal;
  ppx_here = addBase osuper.ppx_here;
  ppx_js_style = addBase osuper.ppx_js_style;
  ppx_module_timer = addStdio osuper.ppx_module_timer;
  ppx_optcomp = addStdio osuper.ppx_optcomp;
  ppx_optional = addBase osuper.ppx_optional;
  ppx_stable = addBase osuper.ppx_stable;

  ppx_expect = osuper.ppx_expect.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ stdio ];
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_expect/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "15r0k8pvl7n53n2kzhdyyyh5am7z721gdcn6v8a18l11x63algnx";
    };
  });

  ppx_sexp_conv = osuper.ppx_sexp_conv.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_sexp_conv/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "179f1iz504l008b3p3d9q2nj44wv7y31pc997x32m6aq1j2lfip3";
    };
  });

  ppx_yojson_conv = (janePackage {
    pname = "ppx_yojson_conv";
    version = "0.15.0";
    hash = "sha256-FGtReLkdI9EnD6sPsMQSv5ipfDyY6z5fIkjqH+tie48=";
    propagatedBuildInputs = [ ppxlib ppx_yojson_conv_lib ppx_js_style ];
    meta = {
      description = "Yojson Deriver PPX";
    };
  }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_yojson_conv/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "1kagc5zk3kbnhvwz4bli9v75wwx3mrj7id1bd2r28ninf45d515f";
    };
  });

  sexp_pretty = osuper.sexp_pretty.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/sexp_pretty/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "1s77hxxsn3scy5gcyxrbq02f4ckhxhm1r6if5fsglj490qk0q5by";
    };
  });

  virtual_dom = osuper.virtual_dom.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/virtual_dom/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "05ijxyn6l91zw5n482njw4ajv5v91phamf6an32i90a5hwrah7vz";
    };
  });

  incr_dom = osuper.incr_dom.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/incr_dom/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "038qmrip2l1vaya602cv973qixz5d4dc8qqvgwfbc26b59a68ljn";
    };
    patches = [ ];
  });

  incr_dom_interactive = janePackage {
    pname = "incr_dom_interactive";
    version = "0.15.0";
    hash = "sha256-G+bgJKDHf78B2m/ZXVVeKf2pk+nk4U14ihmSxv8mbXc=";
    meta.description = "A monad for composing chains of interactive UI elements";
    propagatedBuildInputs = [
      async_js
      async_kernel
      incr_dom
      incr_map
      incr_select
      incremental
      ppx_jane
      splay_tree
      virtual_dom
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  };

  incr_dom_partial_render = janePackage {
    pname = "incr_dom_partial_render";
    version = "0.15.1";
    hash = "sha256-ZKY/b6MCPk4y1sDCRcGK/J6hh/NZmI+lMYMri5Na+i4=";
    meta.description = "A library for simplifying rendering of large amounts of data";
    propagatedBuildInputs = [
      incr_dom
      ppx_jane
      splay_tree
      virtual_dom
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  };

  incr_dom_sexp_form = janePackage {
    pname = "incr_dom_sexp_form";
    version = "0.15.1";
    hash = "sha256-AC/Lws3dax01+0mu+kmmYKYMtQ7zDKwCemYQv3yRjs8=";
    meta.description = "A library for simplifying rendering of large amounts of data";
    propagatedBuildInputs = [
      incr_dom
      incr_dom_interactive
      incr_map
      incr_select
      incremental
      ppx_jane
      splay_tree
      virtual_dom
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  };

  tsdl = osuper.tsdl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/tsdl/archive/refs/tags/v0.9.9.tar.gz;
      sha256 = "120vinx1r3gghq3m6g7ybnr2n7cq8hrqpd7ay2hjc0kb6vk13x00";
    };
    patches = [ ./tsdl.patch ];
    propagatedBuildInputs =
      o.propagatedBuildInputs
      ++ [ ctypes-foreign ]
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        Cocoa
        CoreAudio
        CoreVideo
        AudioToolbox
        ForceFeedback
      ]);
  });

  mlt_parser = janePackage {
    pname = "mlt_parser";
    version = "0.15.0";
    hash = "sha256-ozJMpvfAfLB4zJNy4N6b7raDDz0aKH5KPZQdYB82H0s=";
    meta.description = "Parsing of top-expect files";
    propagatedBuildInputs = [
      core
      ppx_here
      ppx_jane
      ppxlib
    ];
  };

  toplevel_backend = janePackage {
    pname = "toplevel_backend";
    version = "0.15.1";
    hash = "sha256-vYM3l+ZLIXV5AYl3zvovjhnzvJciZL/2Fyn8ETH++aI=";
    meta.description = "Shared backend for setting up toplevels";
    propagatedBuildInputs = [
      findlib
      core
      ppx_here
      ppx_jane
    ];
  };

  toplevel_expect_test = janePackage {
    pname = "toplevel_expect_test";
    version = "0.15.1";
    hash = "sha256-Dhw8J4n2BPE1ZYHL1c7rAk0i2SNeap/BqZUaulQ1jGs=";
    meta.description = "Expectation tests for the OCaml toplevel";
    propagatedBuildInputs = [
      core
      core_unix
      mlt_parser
      toplevel_backend
      ppx_expect
      ppx_jane
      ppx_inline_test
    ];
  };
} // (
  if lib.versionAtLeast osuper.ocaml.version "5.0"
  then (import ./ocaml5.nix oself)
  else { }
)
