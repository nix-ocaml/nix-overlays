{ fetchpatch
, fetchFromGitHub
, lib
, libpq
, darwin
, stdenv
, openssl-oc
, pkg-config
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
    let pkg-config-pkg =
      if stdenv.cc.targetPrefix == ""
      then "${pkg-config}/bin/pkg-config"
      else "${stdenv.cc.targetPrefix}pkg-config";
    in
    writeScriptBin "pkg-config" ''
      #!${stdenv.shell}
      ${pkg-config-pkg} $@
    '';

  disableTests = d: d.overrideAttrs (_: { doCheck = false; });
in

with oself;

{
  alcotest = osuper.alcotest.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/alcotest/releases/download/1.5.0/alcotest-js-1.5.0.tbz;
      sha256 = "0v4ghia378g3l53r61fj98ljha0qxl82xp26y9frjy1dw03ija2l";
    };
    # A snapshot test is failing because of the cmdliner upgrade.
    doCheck = false;
  });

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

  atd = osuper.atd.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/atd/archive/ac9b826354e3b2103b8b95599c26e04b7868d0bf.tar.gz;
      sha256 = "1108c9dhadp8mh925jrfnr83my0rsnpsxhrl2my3fgzq738lrx2l";
    };

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
    src = builtins.fetchurl {
      url = https://github.com/aantron/bisect_ppx/archive/refs/tags/2.8.0.tar.gz;
      sha256 = "0xsk7kvc2drx5llb7mws9d5iavfk0k2qlfkpki1k5acyvdj6yvhd";
    };
    postPatch = ''
      substituteInPlace src/ppx/register.ml --replace "String.uppercase" "String.uppercase_ascii"
      substituteInPlace src/runtime/native/runtime.ml --replace "String.uppercase" "String.uppercase_ascii"
    '';
  });

  bos = osuper.bos.overrideAttrs
    (_: {
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

  camlp5 = osuper.camlp5.overrideAttrs (o: {
    postPatch = ''
      cp -r ./ocaml_stuff/4.14.0 ./ocaml_stuff/5.00.0
      cp ./ocaml_src/lib/versdep/4.14.0.ml ./ocaml_src/lib/versdep/5.00.0.ml
      substituteInPlace odyl/odyl.ml --replace "Printexc.catch" ""
      substituteInPlace ocaml_src/odyl/odyl.ml --replace "Printexc.catch" ""
      patchShebangs ./etc/META.pl
    '';
    nativeBuildInputs = [ ocaml findlib ];
    propagatedBuildInputs = [ camlp-streams fmt fix ];

    src = builtins.fetchurl {
      url = https://github.com/camlp5/camlp5/archive/610c5f3.tar.gz;
      sha256 = "0p2w37r3scf5drv179s99nrygvr1rfa5cm84rgfypmjgg90h3n8m";
    };
  });

  camlp-streams = buildDunePackage {
    pname = "camlp-streams";
    version = "5.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml/camlp-streams/archive/refs/tags/v5.0.tar.gz;
      sha256 = "09njlhzg9pqkz5d5cpqqcrbn70zfgpgdrn8131d0fxm8ayxii9ns";
    };
  };

  camlzip = osuper.camlzip.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/xavierleroy/camlzip/archive/refs/tags/rel111.tar.gz;
      sha256 = "0dzdspqp9nzx8wyhclbm68dykvfj6b97c8r7b47dq4qw7vgcbfzz";
    };
    nativeBuildInputs = [ ocaml findlib ];
    propagatedBuildInputs = [ zlib-oc ];
  });

  camomile = osuper.camomile.overrideAttrs (_: {
    patches = [ ./camomile.patch ];
    postPatch =
      if lib.versionAtLeast ocaml.version "5.00" then ''
        substituteInPlace Camomile/dune --replace " bigarray" ""
        substituteInPlace Camomile/toolslib/dune --replace " bigarray" ""
      '' else "";
    propagatedBuildInputs = [ camlp-streams ];
  });

  coin = osuper.coin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/coin/releases/download/v0.1.4/coin-0.1.4.tbz;
      sha256 = "0069qqswd1ik5ay3d5q1v1pz0ql31kblfsnv0ax0z8jwvacp3ack";
    };
  });

  astring = osuper.astring.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib topkg ocamlbuild ];
  });

  rresult = osuper.rresult.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib topkg ocamlbuild ];
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
    nativeBuildInputs = [ nativeCairo gtk2.dev pkg-config dune-configurator ];
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

  carton = disableTests osuper.carton;

  caqti = osuper.caqti.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-caqti/releases/download/v1.6.0/caqti-v1.6.0.tbz;
      sha256 = "0kb7phb3hbyz541nhaw3lb4ndar5gclzb30lsq83q0s70pbc1w0v";
    };
  });

  cmdliner_1_1 = osuper.cmdliner.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/cmdliner/archive/refs/tags/v1.1.0.tar.gz;
      sha256 = "0617piq2ykfxk0mi9vvyi98pgdy4xav3ji9s7kk2a27sa6k6qns3";
    };
    buildPhase = "make all PREFIX=$out";
    installPhase = ''
      make install LIBDIR=$OCAMLFIND_DESTDIR/cmdliner
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

  ctypes-0_17 = osuper.ctypes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
      sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
    };

    postPatch = ''
      substituteInPlace ./Makefile --replace "bigarray" ""
    '';
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
    doCheck = false;
    patches = [ ./crowbar_multicore.patch ];
  });

  dataloader = callPackage ./dataloader { };
  dataloader-lwt = callPackage ./dataloader/lwt.nix { };

  decimal = callPackage ./decimal { };

  domainslib =
    if lib.versionAtLeast ocaml.version "5.00" then
      callPackage ./domainslib { }
    else null;

  dream = callPackage ./dream {
    multipart_form = multipart_form.override { upstream = true; };
  };

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

  dune_2 = osuper.dune_2.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/dune/archive/435f026896a0410546c4cef73c005bbca364a177.tar.gz;
      sha256 = "1jqiaqxyab487f2gzghy5l10asljkb824xjaryl2vpck85yiqbp1";
    };
    buildInputs = lib.optional stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      Foundation
      CoreServices
    ]);
  });
  dune-configurator = callPackage ./dune/configurator.nix { };
  dyn = callPackage ./dune/dyn.nix { };
  ordering = callPackage ./dune/ordering.nix { };
  stdune = callPackage ./dune/stdune.nix { };
  fiber = callPackage ./dune/fiber.nix { };
  xdg = callPackage ./dune/xdg.nix { };
  dune-private-libs = callPackage ./dune/private-libs.nix { };
  dune-rpc = callPackage ./dune/rpc.nix { };
  dune-rpc-lwt = callPackage ./dune/rpc-lwt.nix { };
  dune-action-plugin = callPackage ./dune/action-plugin.nix { };
  dune-glob = callPackage ./dune/glob.nix { };
  dune-site = callPackage ./dune/site.nix { };

  dune-release = osuper.dune-release.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/dune-release/releases/download/1.6.0/dune-release-1.6.0.tbz;
      sha256 = "07jrra3wdm733bvimzh1j85jmws8dsp7gxwlbz8my0chh9c706qf";
    };
    doCheck = false;
    patches = [ ];
  });

  easy-format = callPackage ./easy-format { };

  ezgzip = buildDunePackage rec {
    pname = "ezgzip";
    version = "0.2.3";
    src = builtins.fetchurl {
      url = "https://github.com/hcarty/${pname}/archive/v${version}.tar.gz";
      sha256 = "0zjss0hljpy3mxpi1ccdvicb4j0qg5dl6549i23smy1x07pr0nmr";
    };
    propagatedBuildInputs = [ rresult astring ocplib-endian camlzip result ];
  };

  findlib = osuper.findlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/ocamlfind/archive/refs/tags/findlib-1.9.3.tar.gz;
      sha256 = "0034x8hb8wdw5mv9kh7rjhf1az2b7qbbdrx56lkr3hm370nprzvq";
    };
    patches = [ ./ldconf.patch ./install_topfind.patch ];
  });

  fix = osuper.fix.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/fix/-/archive/20220121/archive.tar.gz;
      sha256 = "1bd8xnk3qf7nfsmk3z6hksvcascndbl7pp2a50ndj8hzf7hdnfwm";
    };
  });

  flow_parser = callPackage ./flow_parser { };

  fmt = osuper.fmt.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/fmt/archive/e76a883424a450ea10824b69a476f8987fab24c7.tar.gz;
      sha256 = "0ynxq5bv4sjrza4rv52hcvxya31n9n5vvnskk26r1pamxbpagw57";
    };
  });

  fpath = osuper.fpath.overrideAttrs (_: {
    nativeBuildInputs = [ ocaml findlib ocamlbuild topkg ];
    buildInputs = [ ];
  });

  fileutils = osuper.fileutils.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
    postPatch = ''
      substituteInPlace "src/lib/fileutils/dune" --replace "(libraries " "(libraries camlp-streams "
    '';
  });

  gapi_ocaml = osuper.gapi_ocaml.overrideAttrs (_: {
    patches = [ ./gapi.patch ];
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
    nativeBuildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ seq ];
  };

  gettext-stub = disableTests osuper.gettext-stub;

  gg = osuper.gg.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/gg/archive/refs/tags/v1.0.0.tar.gz;
      sha256 = "1vp46w9pwc94fj857xmbzq1ngp48y9b9fyvliaizmbzhhl8dx684";
    };
    nativeBuildInputs = [ ocaml findlib ocamlbuild topkg ];

    buildPhase = ''
      runHook preBuild
      ${topkg.buildPhase}
      runHook postBuild
    '';
  });

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

  gsl = osuper.gsl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mmottl/gsl-ocaml/archive/76f8d93cc.tar.gz;
      sha256 = "0s1h7xrlmq8djaxywq48s1jm7x5f6j7mfkljjw8kk52dfjsfwxw0";
    };
    postPatch = ''
      substituteInPlace ./src/dune --replace "bigarray" ""
      substituteInPlace ./src/wrappers.h --replace "copy_double" "caml_copy_double"
      substituteInPlace ./src/wrappers.h --replace "alloc_small" "caml_alloc_small"
      substituteInPlace ./src/mlgsl_matrix.h --replace "alloc_small" "caml_alloc_small"

    '';
  });

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  hpack = callPackage ./h2/hpack.nix { };

  hacl_x25519 = osuper.hacl_x25519.overrideAttrs (_: { doCheck = false; });

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

  hxd = osuper.hxd.overrideAttrs (_: {
    doCheck = false;
  });

  integers = osuper.integers.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/signed.ml --replace "Pervasives" "Stdlib"
      substituteInPlace ./src/unsigned.ml --replace "Pervasives" "Stdlib"
    '';
  });

  io-page-unix = osuper.io-page-unix.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib/dune --replace "bigarray" ""
    '';
  });

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  iter = osuper.iter.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/iter/archive/8be24288.tar.gz;
      sha256 = "0hkgia50lqwh13b5f0515z2w17q8pqd3nrnza76ns9h34qag55l9";
    };
    postPatch = ''
      substituteInPlace "src/dune" --replace "(libraries " "(libraries camlp-streams "
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
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

  js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/js_of_ocaml/releases/download/4.0.0/js_of_ocaml-4.0.0.tbz;
      sha256 = "0pj9jjrmi0xxrzmygv4b5whsibw1jxy3wgibmws85x5jwlczh0nz";
    };
  });

  js_of_ocaml-ocamlbuild = osuper.js_of_ocaml-ocamlbuild.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/js_of_ocaml-ocamlbuild/archive/852302c8f35b946e2ec275c529a79e46d8749be6.tar.gz;
      sha256 = "11dj6sg77bzmnrja2vjsaarpwzfn1gbqia2l6y4pml5klpp712iv";
    };
  });

  kafka = osuper.kafka.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib/ocaml_kafka.c --replace "= alloc_small" "= caml_alloc_small"
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

  lacaml = osuper.lacaml.overrideAttrs (_: {
    postPatch =
      if lib.versionAtLeast ocaml.version "5.00" then ''
        substituteInPlace src/dune --replace " bigarray" ""
      '' else "";
  });

  lmdb = osuper.buildDunePackage {
    pname = "lmdb";
    version = "1.0";
    src = builtins.fetchurl {
      url = https://github.com/Drup/ocaml-lmdb/archive/1.0.tar.gz;
      sha256 = "0nkax7v4yggk21yxgvx3ax8fg74yl1bhj4z09szfblmsxsy5ydd4";
    };
    nativeBuildInputs = [ pkg-config-script dune-configurator pkg-config ];
    buildInputs = [ lmdb-pkg ];
    propagatedBuildInputs = [ bigstringaf ];
  };

  lwt = osuper.lwt.overrideAttrs (o: {
    version = "5.5.0";
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ bigarray-compat ];
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/lwt/archive/34f98c6.tar.gz;
      sha256 = "0hp4kzj2h4ayspjkwhx2f8aiscbb9r6lcm2kx88yfw0nd4dm3qfj";
    };
  });

  lwt-watcher = osuper.lwt-watcher.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/70f826c503cc094ed2de3aa81fa385ea9fddb903.tar.gz;
      sha256 = "0q1qdmagldhwrcqiinsfag6zxcn5wbvn2p10wpyi8rgk27q3l8sk";
    };
  });

  lwt_react = callPackage ./lwt/react.nix { };

  lwt_log = osuper.lwt_log.overrideAttrs (_: {
    prePatch = ''
      substituteInPlace src/core/lwt_log_core.ml --replace "String.lowercase" "String.lowercase_ascii"
    '';
  });

  markup = osuper.markup.overrideAttrs (o: {
    prePatch = ''
      substituteInPlace src/common.ml --replace " = lowercase" " = lowercase_ascii"
    '';
  });

  mustache = osuper.mustache.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/rgrinberg/ocaml-mustache/archive/d0c45499f9a5ee91c38cf605ae20ecee47142fd8.tar.gz;
      sha256 = "0dl7islmm9pdwmbkj9dfvbw16kvaxf47w34x38hgqlgvqyfdvcp8";
    };

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ cmdliner ];
  });

  jose = callPackage ./jose { };

  ke = osuper.ke.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ke/archive/56a8c86.tar.gz;
      sha256 = "1n8yfjpmhga4mqh17r8z2qs9kw13bsl3022lplijw9ys0cwicii0";
    };
  });

  lambda-runtime = callPackage ./lambda-runtime { };
  vercel = callPackage ./lambda-runtime/vercel.nix { };

  lambdaTerm = osuper.lambdaTerm.overrideAttrs (_: {
    prePatch = ''
      substituteInPlace src/lTerm_key.ml --replace "StringLabels.lowercase" "StringLabels.lowercase_ascii"
      substituteInPlace src/lTerm_resources.ml --replace "StringLabels.lowercase" "StringLabels.lowercase_ascii"
      substituteInPlace src/lTerm_text_impl.ml --replace "mark_open_tag" "mark_open_stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "mark_close_tag" "mark_close_stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "print_open_tag" "print_open_stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "print_close_tag" "print_close_stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "Format.pp_set_formatter_tag_functions" "Format.pp_set_formatter_stag_functions"
      substituteInPlace src/lTerm_text_impl.ml --replace "Format.pp_open_tag" "Format.pp_open_stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "Format.pp_close_tag" "Format.pp_close_stag"
      substituteInPlace src/lTerm_text.mli --replace "Format.tag" "Format.stag"
      substituteInPlace src/lTerm_text_impl.ml --replace "Format.tag" "Format.stag"
    '';
  });

  logs = osuper.logs.override { jsooSupport = false; };

  logs-ppx = callPackage ./logs-ppx { };

  landmarks = callPackage ./landmarks { };
  landmarks-ppx = callPackage ./landmarks/ppx.nix { };

  melange =
    if (lib.versionOlder "4.12" osuper.ocaml.version && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange { }
    else null;

  melange-compiler-libs =
    if ((lib.versionOlder "4.12" osuper.ocaml.version) && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange/compiler-libs.nix { }
    else null;

  # This overrides Menhir too.
  menhirLib = osuper.menhirLib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/menhir/-/archive/e5c3087028286016ed72880fe5e702077b28441a.tar.gz;
      sha256 = "0pis7mghrnl5ahqv3gm0ybjb1032ifixsnfz5skg6n8jl4pggi2w";
    };
  });

  dot-merlin-reader = callPackage ./merlin/dot-merlin.nix { };
  merlin = callPackage ./merlin { };

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

  morph = callPackage ./morph { };
  morph_graphql_server = callPackage ./morph/graphql.nix { };

  mongo = callPackage ./mongo { };
  mongo-lwt = callPackage ./mongo/lwt.nix { };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { };
  bson = callPackage ./mongo/bson.nix { };

  mrmime = osuper.mrmime.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];

    # https://github.com/mirage/mrmime/issues/91
    doCheck = !lib.versionAtLeast ocaml.version "5.00";
  });

  mtime = osuper.mtime.override { jsooSupport = false; };

  multipart_form = callPackage ./multipart_form { };

  multipart-form-data = callPackage ./multipart-form-data { };

  nocrypto = buildDunePackage {
    pname = "nocrypto";
    version = "0.5.4+dune";
    src = builtins.fetchurl {
      url = https://github.com/mirleft/ocaml-nocrypto/archive/b31c381.tar.gz;
      sha256 = "1ajyiz48zr5wpc48maxfjn4sj9knrmbcdzq0vn407fc3y0wdxf52";
    };
    nativeBuildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ cstruct ppx_deriving ppx_sexp_conv sexplib zarith cstruct-lwt cpuid ];

  };
  bigarray-compat = osuper.bigarray-compat.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/bigarray-compat/releases/download/v1.1.0/bigarray-compat-1.1.0.tbz;
      sha256 = "1m8q6ywik6h0wrdgv8ah2s617y37n1gdj4qvc86yi12winj6ji23";
    };

  });
  bigstring = osuper.bigstring.overrideAttrs (_: {

    postPatch =
      if lib.versionAtLeast ocaml.version "5.00" then ''
        substituteInPlace src/dune --replace " bigarray" ""
      '' else "";
  });
  mmap = osuper.mmap.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mmap/archive/41596aa.tar.gz;
      sha256 = "0fxv8qff9fsribymjgka7rq050i9yisph74nx642i5z7ng8ahlxq";
    };
  });



  num = osuper.num.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/num/archive/v1.4.tar.gz;
      sha256 = "090gl27g84r3s2b12vgkz8fp269jqlrhx4lpg7008yviisv8hl01";
    };

    patches = [ ./num/findlib-install.patch ];
  });

  ocaml = (osuper.ocaml.override { flambdaSupport = true; }).overrideAttrs (_: {
    enableParallelBuilding = true;
    makefile = ./ocaml-Makefile.nixpkgs;
    buildFlags = [ "nixpkgs_world_bootstrap_world_opt" ];
  });

  ocamlbuild = osuper.ocamlbuild.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/ocamlbuild/archive/ecbfefb69659085de7e3e45e0ce1848987b06101.tar.gz;
      sha256 = "1irh4nph089fk6imlr5yxymz6spmlipqf93wpxx5mf4wbwydwryw";
    };
  });

  ocaml_extlib-1-7-8 = osuper.ocaml_extlib-1-7-8.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ygrek/ocaml-extlib/archive/9e9270de9d6c33e08a18096f7fb75b4205e6c1ed.tar.gz;
      sha256 = "006zc8jc1zx20iis06z3gppmikc6pfarx5ikdhihggk7k1wam6c1";
    };
  });

  # Tests don't work on 5.00 because of the Stream.t type.
  ocaml_gettext = osuper.ocaml_gettext.overrideAttrs (_: { doCheck = false; });

  ocamlnet = osuper.ocamlnet.overrideAttrs (o:
    let
      script = writeScriptBin "cpp" ''
        #!${stdenv.shell}
        ${stdenv.hostPlatform.config}-cpp $@
      '';
    in
    {
      nativeBuildInputs = o.nativeBuildInputs ++ [ ocaml findlib ];
    });

  ocaml-lsp =
    if lib.versionOlder "4.13" osuper.ocaml.version then null
    else osuper.ocaml-lsp;

  inherit (callPackage ./ocamlformat-rpc { })
    ocamlformat-rpc# latest version
    ocamlformat-rpc_0_20_0
    ocamlformat-rpc_0_20_1;

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [
      pkg-config-script
      dune-configurator
    ];
  });

  ocp-build = osuper.ocp-build.overrideDerivation (o: {
    preConfigure = "";
  });

  ocplib-endian = osuper.ocplib-endian.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocamlpro/ocplib-endian/archive/7179dd6e66.tar.gz;
      sha256 = "1rgncdbbwa5j0wx0p8n44y29mpx98v6fmy8s0djri12frlm0k5dl";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo ];
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

  oauth = callPackage ./oidc/oauth.nix { };
  oidc = callPackage ./oidc { };
  oidc-client = callPackage ./oidc/client.nix { };

  ocsigen-toolkit = osuper.ocsigen-toolkit.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/ocsigen-toolkit/archive/499e8260df6487ebdacb9fcccb2f9dec36df8063.tar.gz;
      sha256 = "10zlgp7wmrwwzq6298y7q4hlsmpq587vlcppj81hly3as1jq16ni";
    };
  });

  odoc = callPackage ./odoc { };
  odoc-parser = osuper.odoc-parser.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace "src/dune" --replace "(libraries " "(libraries camlp-streams "
    '';
    propagatedBuildInputs = [ camlp-streams ];

  });

  ounit2 = osuper.ounit2.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/gildor478/ounit/releases/download/v2.2.6/ounit-2.2.6.tbz;
      sha256 = "04src5dc95bchimvnlbxih78pn95336b6rimbknqx8ch1qggp406";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ seq ];
  });

  parmap = osuper.parmap.overrideAttrs (_: {
    doCheck = false;
  });

  pg_query = callPackage ./pg_query { };

  piaf = callPackage ./piaf { };
  carl = callPackage ./piaf/carl.nix { };

  pp = osuper.pp.overrideAttrs (_: { doCheck = false; });

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ppx/dune --replace " bigarray" ""
    '';
    # To avoid bringing in OMP
    doCheck = false;
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  ppxlib = osuper.ppxlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppxlib/archive/31621eedacfa412ad59572d0d09a4d1b86553b3a.tar.gz;
      sha256 = "01bk8sshy7cma309iq9g32r6kwxrniy4vw3j9dss5qfwi6m9f21s";
    };
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      stdio
      stdlib-shims
    ];
  });

  ppx_tools = callPackage ./ppx_tools { };

  postgresql =
    (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (_: {
      postPatch = ''
        substituteInPlace src/dune --replace " bigarray" ""
      '';
    });

  postgres_async = osuper.buildDunePackage {
    pname = "postgres_async";
    version = "0.14.0";
    src = builtins.fetchurl {
      url = https://ocaml.janestreet.com/ocaml-core/v0.14/files/postgres_async-v0.14.0.tar.gz;
      sha256 = "0pspfk4bsknxi0hjxav8z1r1y9ngkbq9iw9igy85rxh4a7c92s51";
    };
    propagatedBuildInputs = [ ppx_jane core core_kernel async ];
  };

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo ];
    buildInputs = [ ];
    propagatedBuildInputs = [
      ppxlib
      ppx_derivers
      result
    ];
    # Tests use `Pervasives`.
    doCheck = false;
  });

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/e030f13a3.tar.gz;
      sha256 = "0yfb5c8g8h40m4b722qfl00vgddj6apzcd2lhzv01npn2ipnm280";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ppx_blob = osuper.ppx_blob.overrideAttrs (_: { doCheck = false; });

  printbox-text = osuper.printbox-text.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/printbox/archive/refs/tags/v0.6.tar.gz;
      sha256 = "1hr6g23b8z0p9kk1g996bzbrrziqk9b2c1za5xyzcq5g3xxqipij";
    };
    preBuild = "rm -rf ./dune";
    doCheck = false;
  });

  ptime = (osuper.ptime.override { jsooSupport = false; }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/ptime/archive/refs/tags/v0.8.6.tar.gz;
      sha256 = "0ch52j7raj1av2bj1880j47lv18p4x0bfy6l3gg4m10v9mycl5r3";
    };
  });

  pycaml = osuper.pycaml.overrideAttrs (o: {
    installPhase = ''
      runHook preInstall
      ${o.installPhase}
      runHook postInstall
    '';
  });

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

  reason-native = osuper.reason-native // { qcheck-rely = null; };

  react = osuper.react.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/react/archive/aebf35179964e73a7ef557c6a56175c7abdb9947.tar.gz;
      sha256 = "04rqmigdbgah4yvdjpk3ai9j7d3zhp2hz2qd482p1q2k3bbn52kh";
    };
  });

  re = osuper.re.overrideAttrs (_: {
    # Tests use `String.capitalize` which was removed in 5.00
    doCheck = false;
  });

  redemon = callPackage ./redemon { };
  redis = callPackage ./redis { };
  redis-lwt = callPackage ./redis/lwt.nix { };
  redis-sync = callPackage ./redis/sync.nix { };

  reenv = callPackage ./reenv { };

  rock = callPackage ./opium/rock.nix { };
  opium = callPackage ./opium { };

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anuragsoni/routes/releases/download/1.0.0/routes-1.0.0.tbz;
      sha256 = "1s24lbfkbyj5a873viy811vs8hrfxvsz7dqm6vz4bmf06i440aar";
    };
  });

  sedlex = oself.sedlex_2;

  session = callPackage ./session { };
  session-redis-lwt = callPackage ./session/redis.nix { };

  sodium = buildDunePackage {
    pname = "sodium";
    version = "0.8+ahrefs";
    src = builtins.fetchurl {
      url = https://github.com/ahrefs/ocaml-sodium/archive/4c92a94a330f969bf4db7fb0ea07602d80c03b14.tar.gz;
      sha256 = "1dmddcg4v1g99cbgvkhdpz2c3xrdlmn3asvr5mhdjfggk5bbzw5f";
    };
    patches = [ ./sodium-cc-patch.patch ];
    propagatedBuildInputs = [ ctypes libsodium ];
  };

  ssl = osuper.ssl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/savonet/ocaml-ssl/archive/35e6dfa.tar.gz;
      sha256 = "1h2z0g9ghnj7q3xjjw7h5hh9ijdj19lfbg5lrpw3q8hb1frlz729";
    };

    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl-oc.dev ];
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

  toml = osuper.toml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-toml/to.ml/archive/41172b739dff43424a12f7c1f0f64939e3660648.tar.gz;
      sha256 = "0ck5bqyly3hxdb0kqgkjjl531893r7m4bhk6i93bv1wq2y58igzq";
    };

    preConfigure = ''
      echo '(using menhir 2.1)' >> ./dune-project
    '';
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

  tyxml-jsx = callPackage ./tyxml/jsx.nix { };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { };

  # These require crowbar which is still not compatible with newer cmdliner.
  pecu = osuper.pecu.overrideAttrs (_: { doCheck = false; });
  unstrctrd = osuper.unstrctrd.overrideAttrs (_: { doCheck = false; });

  utop = osuper.utop.overrideAttrs (_: {
    version = "2.9.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/utop/releases/download/2.9.0/utop-2.9.0.tbz;
      sha256 = "17jd61bc6pva5wqmnc9xq70ysyjplrzf1p25sq1s7wgrfq2vlyyd";
    };

    prePatch = ''
      substituteInPlace src/lib/uTop_main.ml --replace "Clflags.unsafe_string" "(ref false)"
    '';
  });

  uuidm = osuper.uuidm.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/uuidm/archive/da1de441840fd457b21166448f9503fcf6dc6518.tar.gz;
      sha256 = "0vpdma904jmw42g0lav153yqzpzwlkwx8v0c8w39al8d2r4nfdb1";
    };
    buildPhase = "ocaml -I ${findlib}/lib/ocaml/${ocaml.version}/site-lib/ pkg/pkg.ml build --with-cmdliner false";
  });

  uunf = osuper.uunf.overrideAttrs (_: {
    buildPhase = ''
      # big enough stack size
      export OCAMLRUNPARAM="l=1100000"
      ${topkg.buildPhase}
    '';
  });

  uutf = osuper.uutf.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/uutf/archive/refs/tags/v1.0.3.tar.gz;
      sha256 = "1520njh9qaqflnj1xaawwhxdmn7r1p3wrh1j7w8y91g5y3zcp95z";
    };
  });

  uuuu = osuper.uuuu.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/uuuu/releases/download/v0.3.0/uuuu-0.3.0.tbz;
      sha256 = "19n39yc7spgzpk9i70r0nhkwsb0bfbvbgpf8d863p0a3wgryhzkb";
    };
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

  xmlm = osuper.xmlm.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/xmlm/archive/refs/tags/v1.4.0.tar.gz;
      sha256 = "1qx89nzwv9qx6zw9xbrzlsvpmxwb30iji41kdw10x40ylwfnra4x";
    };
  });

  yojson = osuper.yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/yojson/archive/0fc0bb781d70a3a754bbbd2a2ed4508b07092278.tar.gz;
      sha256 = "1qimfilgawr8r55hc33cs1l5hi0iqd62z4mvh1qhxhxby4w1wviw";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
    patches = [ ./camlpstreams.patch ];
  });

  yuscii = osuper.yuscii.overrideAttrs (_: { doCheck = false; });

  # Jane Street packages
  async_websocket = osuper.buildDunePackage {
    pname = "async_websocket";
    version = "0.14.0";
    src = builtins.fetchurl {
      url = https://ocaml.janestreet.com/ocaml-core/v0.14/files/async_websocket-v0.14.0.tar.gz;
      sha256 = "1q630fd5wyyfg07jrsw9f57hphmrp7pkcy4kz5gggkfqn1kkfkph";
    };
    propagatedBuildInputs = [ ppx_jane cryptokit async core_kernel ];
  };


  async_ssl = janePackage {
    pname = "async_ssl";
    hash = "0ykys3ckpsx5crfgj26v2q3gy6wf684aq0bfb4q8p92ivwznvlzy";
    meta.description = "Async wrappers for SSL";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ async ctypes-0_17 openssl-oc ];
  };

  base = osuper.base.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/base/archive/a3cf0042e943c9c979ff7424912c71c6236f68f3.tar.gz;
      sha256 = "0i625xddnhqs67bd23gz7vifig83bacx6k9k94sns59h177h2wkb";
    };
  });

  base_quickcheck = (janePackage {
    pname = "base_quickcheck";
    hash = "1lmp1h68g0gqiw8m6gqcbrp0fn76nsrlsqrwxp20d7jhh0693f3j";
    minimumOCamlVersion = "4.04.2";
    meta.description = "Randomized testing framework, designed for compatibility with Base";
    propagatedBuildInputs = [ ppx_base ppx_fields_conv ppx_let ppx_sexp_value splittable_random ];
  }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/base_quickcheck/archive/v0.14.1.tar.gz;
      sha256 = "0n5h0ysn593awvz4crkvzf5r800hd1c55bx9mm9vbqs906zii6mn";
    };
  });

  bin_prot = osuper.bin_prot.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  core = (janePackage {
    pname = "core";
    hash = "1m9h73pk9590m8ngs1yf4xrw61maiqmi9glmlrl12qhi0wcja5f3";
    meta.description = "System-independent part of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ core_kernel spawn timezone ];
    doCheck = false; # we don't have quickcheck_deprecated
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/core/archive/596b31f37c30acc5ca8e8c1029dbc753d473bc31.tar.gz;
      sha256 = "1k0l9q1k9j5ccc2x40w2627ykzldyy8ysx3mmkh11rijgjjk3fsf";
    };
  });

  core_kernel = (janePackage {
    pname = "core_kernel";
    hash = "012sp02v35j41lzkvf073620602fgiswz2n224j06mk3bm8jmjms";
    meta.description = "System-independent part of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ base_bigstring sexplib ];
    doCheck = false; # we don't have quickcheck_deprecated
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/core_kernel/archive/v0.14.1.tar.gz;
      sha256 = "0f24sagyzhfr6x68fynhsn5cd1p72vkqm25wnfg8164sivas148x";
    };
  });

  memtrace = osuper.buildDunePackage {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/memtrace/archive/918dcededf1.tar.gz;
      sha256 = "1w1fif25n9h4dk4xkwdyx98x3nwpkdipf74m1dfrv1dhz6qbpls3";
    };
    pname = "memtrace";
    version = "0.1.2-dev";
  };

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

  sexplib0 = osuper.sexplib0.overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.00" then
        builtins.fetchurl
          {
            url = https://github.com/janestreet/sexplib0/archive/f13a9b2.tar.gz;
            sha256 = "10jg2qgwhgb4dcyzs87r2wbwkjpyasnf0gwjm9vj1igdwiyj66rl";
          }
      else o.src;
  });
  sexplib = osuper.sexplib.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/sexplib/archive/eb772fb.tar.gz;
      sha256 = "0k405ks0pyx8849ydws3aiybwj1nx226h3fh5gfqgv8qpp80a8i5";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ bigarray-compat ];
  });

  ppx_accessor = (janePackage {
    pname = "ppx_accessor";
    version = "0.14.2";
    minimumOCamlVersion = "4.09";
    hash = "01nifsh7gap28cpvff6i569lqr1gmyhrklkisgri538cp4pf1wq1";
    meta.description = "[@@deriving] plugin to generate accessors for use with the Accessor libraries";
    propagatedBuildInputs = [ accessor ];
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_accessor/archive/v0.14.3.tar.gz;
      sha256 = "19gq2kg2d68wp5ph8mk5fpai13dafqqd3i23hn76s3mc1lyc3q1a";
    };
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

  ppx_custom_printf = (janePackage {
    pname = "ppx_custom_printf";
    hash = "0p9hgx0krxqw8hlzfv2bg2m3zi5nxsnzhyp0fj5936rapad02hc5";
    minimumOCamlVersion = "4.04.2";
    meta.description = "Printf-style format-strings for user-defined string conversion";
    propagatedBuildInputs = [ ppx_sexp_conv ];
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_custom_printf/archive/d415134eb9851e0e52357046f2ed642dfc398ba3.tar.gz;
      sha256 = "1ydfpb6aqgj03njxlicydbd9hf8shlqjr2i6yknzsvmwqxpy5qci";
    };
  });

  ppx_expect = (janePackage {
    pname = "ppx_expect";
    hash = "05v6jzn1nbmwk3vzxxnb3380wzg2nb28jpb3v5m5c4ikn0jrhcwn";
    minimumOCamlVersion = "4.04.2";
    meta.description = "Cram like framework for OCaml";
    propagatedBuildInputs = [ ppx_here ppx_inline_test re stdio ];
    doCheck = false; # circular dependency with ppx_jane
  }).overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.00" then
        builtins.fetchurl
          {
            url = https://github.com/janestreet/ppx_expect/archive/13087c65faa754b53f911de2391c2335dfb40b35.tar.gz;
            sha256 = "0j98ba07nmln9a2w1jmc33ahzr6vm5clx3cn79jk3bw8z23jahxn";
          }
      else
        builtins.fetchurl {
          url = https://github.com/janestreet/ppx_expect/archive/7f46c2d22a87b99c70a220c1b13aaa34c6d217ff.tar.gz;
          sha256 = "0vkrmcf1s07qc1l7apbdr8y28x77s8shbsyb6jzwjkx3flyahqmh";
        };
  });

  ppx_sexp_conv = (janePackage {
    pname = "ppx_sexp_conv";
    version = "0.14.1";
    minimumOCamlVersion = "4.04.2";
    hash = "04bx5id99clrgvkg122nx03zig1m7igg75piphhyx04w33shgkz2";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
    propagatedBuildInputs = [ ppxlib sexplib0 base ];
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_sexp_conv/archive/291fd9b59d19e29702e0e3170559250c1f382e42.tar.gz;
      sha256 = "003mzsjy3abqv72rmfnlrjbk24mvl1ck7qz58b8a3xpmgyxz1kq1";
    };
  });

  ppx_sexp_message = (janePackage {
    pname = "ppx_sexp_message";
    hash = "17xnq345xwfkl9ydn05ljsg37m2glh3alnspayl3fgbhmcjmav3i";
    minimumOCamlVersion = "4.04.2";
    meta.description = "A ppx rewriter for easy construction of s-expressions";
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  }).overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_sexp_message/archive/fd604b269398aebdb0c5fa5511d9f3c38b6ecb45.tar.gz;
      sha256 = "1izfs9a12m2fc3vaz6yxgj1f5hl5xw0hx2qs55cbai5sa1irm8lg";
    };
  });

  ppx_typerep_conv = (janePackage {
    pname = "ppx_typerep_conv";
    version = "0.14.1";
    minimumOCamlVersion = "4.04.2";
    hash = "1r0z7qlcpaicas5hkymy2q0gi207814wlay4hys7pl5asd59wcdh";
    meta.description = "Generation of runtime types from type declarations";
    propagatedBuildInputs = [ ppxlib typerep ];
  }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_typerep_conv/archive/v0.14.2.tar.gz;
      sha256 = "1g1sb3prscpa7jwnk08f50idcgyiiv0b9amkl0kymj5cghkdqw0n";
    };
  });

  ppx_variants_conv = (janePackage {
    pname = "ppx_variants_conv";
    version = "0.14.1";
    minimumOCamlVersion = "4.04.2";
    hash = "0q6a43zrwqzdz7aja0k44a2llyjjj5xzi2kigwhsnww3g0r5ig84";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
    propagatedBuildInputs = [ variantslib ppxlib ];
  }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_variants_conv/archive/6103f6fc56f978c847ba7c1f2d9f38ee93a5e337.tar.gz;
      sha256 = "13006x3jl4fdp845rg2s1h01f44w27ij4i85pqll4r286lsvyyqq";
    };
  });

  protocol_version_header = osuper.protocol_version_header.overrideAttrs (_: {
    propagatedBuildInputs = [ core ppx_jane ];
  });
}
