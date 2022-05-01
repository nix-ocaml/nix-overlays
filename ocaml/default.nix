{ fetchpatch
, fetchFromGitHub
, lib
, libpq
, libffi-oc
, darwin
, stdenv
, gmp-oc
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

  batteries = osuper.batteries.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-batteries-team/batteries-included/archive/67859ac54d2feb7f65ad6abe48b1ff08ece3afd1.tar.gz;
      sha256 = "0krsgisyal809nx1xpnbfpd1h3x95s1x3s4vsdpymv4hrxrqxks5";
    };
  });

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
    # https://github.com/aantron/bisect_ppx/pull/400
    src = builtins.fetchurl {
      url = https://github.com/aantron/bisect_ppx/archive/be22c980dd58a2b277ea4710074afbd0bdddbf77.tar.gz;
      sha256 = "162bjhhlkp1afji6mpzpq08ap5gkyy8xi1749jl3vdrz21vy180y";
    };
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

  camlp5 = callPackage ./camlp5 { };

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

  checkseum = osuper.checkseum.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script ];
  });

  containers = osuper.containers.overrideAttrs (o: {
    version = "3.7.0";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/ocaml-containers/archive/v3.7.tar.gz";
      sha256 = "0pn5yl1b6ij1j63qh8y6qazk5qyh1q40zchrwsrsva3yb73s74z9";
    };
  });

  cohttp = osuper.cohttp.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-cohttp/releases/download/v5.0.0/cohttp-5.0.0.tbz;
      sha256 = "01asr99hdfw1qkg8wvnslzb1gxfvjs2n421s3gb5b0w1djwg8vzx";
    };
    checkInputs = o.checkInputs ++ [ crowbar ];
  });
  cohttp-async = osuper.cohttp-async.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace examples/async/dune --replace \
        "async_kernel" "async_kernel core_unix.command_unix"
      substituteInPlace examples/async/hello_world.ml --replace \
        "Command.run" "Command_unix.run"
      substituteInPlace examples/async/receive_post.ml --replace \
        "Command.run" "Command_unix.run"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ core_unix ];
  });

  coin = osuper.coin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/coin/releases/download/v0.1.4/coin-0.1.4.tbz;
      sha256 = "0069qqswd1ik5ay3d5q1v1pz0ql31kblfsnv0ax0z8jwvacp3ack";
    };
  });

  conduit = osuper.conduit.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-conduit/releases/download/v5.1.0/conduit-5.1.0.tbz;
      sha256 = "1kci4cm9m9g50cp0g210cj3dqciq16ahbc49k7hfkfwwhwz8q775";
    };
  });

  bigstringaf = osuper.bigstringaf.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
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

  carton = disableTests osuper.carton;

  cmdliner_1_0 = osuper.cmdliner;

  cmdliner = osuper.cmdliner.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/cmdliner/archive/refs/tags/v1.1.1.tar.gz;
      sha256 = "07846phk06hi90a764ijlrkv9xh69bdn2msi5ah6c43s8pcf7rnv";
    };
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

  ctypes = osuper.ctypes.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ libffi-oc ];
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

    patches = [ ];

    doCheck = lib.versionAtLeast ocaml.version "5.00";
  });

  dataloader = callPackage ./dataloader { };
  dataloader-lwt = callPackage ./dataloader/lwt.nix { };

  decimal = callPackage ./decimal { };

  decompress = disableTests osuper.decompress;

  dns = osuper.dns.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-dns/releases/download/v6.1.4/dns-6.1.4.tbz;
      sha256 = "0xlhfz7qnkpsqcn3fs3y426iwgzy08swbddlwzinvklhad263vww";
    };
  });
  dns-client = osuper.dns-client.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ca-certs ca-certs-nss tls tls-mirage happy-eyeballs tcpip ];
  });
  dns-mirage = osuper.dns-mirage.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ tcpip ];
  });
  dns-resolver = osuper.dns-resolver.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ tls-mirage ];
  });

  dolog = buildDunePackage {
    pname = "dolog";
    version = "6.0.0";
    src = builtins.fetchurl {
      url = https://github.com/UnixJunkie/dolog/archive/refs/tags/v6.0.0.tar.gz;
      sha256 = "0idxs1lnpsh49hvxnrkb3ijybd83phzbxfcichchw511k9ismlia";
    };
  };

  domainslib =
    if lib.versionAtLeast ocaml.version "5.00" then
      callPackage ./domainslib { }
    else null;


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

  dune_3 = osuper.dune_3.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/dune/releases/download/3.1.0/fiber-3.1.0.tbz;
      sha256 = "10cxa4ljajzlhb8jfc2ax8diyymydv3dfmjqxh86xia5105m4z87";
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
      url = https://github.com/ocamllabs/dune-release/releases/download/1.6.1/dune-release-1.6.1.tbz;
      sha256 = "0qxprr21b3qp6rqcd3zmilfypssw227s1c48lpakrkh69g5jxxia";
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
      url = https://github.com/dbuenzli/fmt/archive/e76a883424a450ea10824b69a476f8987fab24c7.tar.gz;
      sha256 = "0ynxq5bv4sjrza4rv52hcvxya31n9n5vvnskk26r1pamxbpagw57";
    };
  });

  fileutils = osuper.fileutils.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
    postPatch = ''
      substituteInPlace "src/lib/fileutils/dune" --replace "(libraries " "(libraries camlp-streams "
    '';
  });

  functoria = osuper.functoria.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/functoria/releases/download/v3.1.2/functoria-3.1.2.tbz;
      sha256 = "1yh0gkf6f2g960mcnrpilhj3xrszr98hy4zkav078f6amxcmwyl4";
    };
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
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ seq ];
  };

  gettext-stub = disableTests osuper.gettext-stub;

  git = osuper.git.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-git/archive/0de355b.tar.gz;
      sha256 = "1x5waa8kandjlf798bd635f1bvnhpkq7hcc3awhg053g9phqfcmv";
    };
  });
  git-unix = osuper.git-unix.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [
      awa
      awa-mirage
      cmdliner
      mirage-clock
      mirage-clock-unix
      tcpip
      git
      happy-eyeballs-lwt
      mirage-unix
    ];
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

  happy-eyeballs = callPackage ./happy-eyeballs { };
  happy-eyeballs-lwt = callPackage ./happy-eyeballs/lwt.nix { };
  happy-eyeballs-mirage = callPackage ./happy-eyeballs/mirage.nix { };

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

  hxd = osuper.hxd.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/dinosaure/hxd/releases/download/v0.3.2/hxd-0.3.2.tbz;
      sha256 = "17zcmdyz8jmi0m8ixsq39jy0d60v62dys8nw5nrpk3jkp2mr00m0";
    };
    doCheck = false;
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  index = disableTests osuper.index;
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

  irmin-fs = disableTests osuper.irmin-fs;
  irmin-chunk = disableTests osuper.irmin-chunk;
  irmin-pack = disableTests osuper.irmin-pack;
  irmin-git = disableTests osuper.irmin-git;
  irmin-http = disableTests osuper.irmin-http;
  # https://github.com/mirage/metrics/issues/57
  irmin-test = null;

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

  jose = callPackage ./jose { };

  kafka = osuper.kafka.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib/ocaml_kafka.c --replace "= alloc_small" "= caml_alloc_small"
    '';
  });

  ke = osuper.ke.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ke/archive/56a8c86.tar.gz;
      sha256 = "1n8yfjpmhga4mqh17r8z2qs9kw13bsl3022lplijw9ys0cwicii0";
    };
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

  lru = osuper.lru.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/lru.ml \
        --replace \
        "include H let hash _ x = hash x" \
        "include H let hash _ x = hash x;; let seeded_hash = hash"
    '';
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

  lwt = osuper.lwt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ bigarray-compat ];
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config cppo ];
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

  mdx = osuper.mdx.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/realworldocaml/mdx/archive/493ed9184cad24ba203c8fe72c12b95a7658eb9a.tar.gz;
      sha256 = "0yh77i0cz9y12cn1xflmrafyhgnw5cc10pd2qh7l956pf8xpkhj3";
    };
  });

  mirage-crypto = osuper.mirage-crypto.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
    buildInputs = [ dune-configurator ];
  });

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
  melange-compiler-libs = callPackage ./melange/compiler-libs.nix { };

  # This overrides Menhir too.
  menhirLib = osuper.menhirLib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/menhir/-/archive/e5c3087028286016ed72880fe5e702077b28441a.tar.gz;
      sha256 = "0pis7mghrnl5ahqv3gm0ybjb1032ifixsnfz5skg6n8jl4pggi2w";
    };
  });

  dot-merlin-reader = callPackage ./merlin/dot-merlin.nix { };
  merlin = callPackage ./merlin { };

  metrics = osuper.metrics.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/metrics/releases/download/v0.4.0/metrics-0.4.0.tbz;
      sha256 = "1bw9wdzmw6xxhaww95xayias1mmypqcmkdf32cbkg42h9dd7bf4i";
    };

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
      url = https://github.com/dinosaure/mimic/archive/d548777d2f33b88ea04b2d0550df020578419b4e.tar.gz;
      sha256 = "17mk21f76yl0yiskybnvd4zwr073m1rh2l5hswj34dyvcfzz153y";
    };

    postPatch = ''
      substituteInPlace lib/implicit.ml --replace "Obj.extension_id" "Obj.Extension_constructor.id"
      substituteInPlace lib/implicit.ml --replace "Stdlib.Obj.((extension_id (extension_constructor t" "Stdlib.Obj.Extension_constructor.((id (of_val t"
      substituteInPlace test/dune --replace "bigarray" ""


    '';
  });

  mrmime = osuper.mrmime.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];

    # https://github.com/mirage/mrmime/issues/91
    doCheck = !lib.versionAtLeast ocaml.version "5.00";
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

  nocrypto = buildDunePackage {
    pname = "nocrypto";
    version = "0.5.4+dune";
    src = builtins.fetchurl {
      url = https://github.com/mirleft/ocaml-nocrypto/archive/b31c381.tar.gz;
      sha256 = "1ajyiz48zr5wpc48maxfjn4sj9knrmbcdzq0vn407fc3y0wdxf52";
    };
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ cstruct ppx_deriving ppx_sexp_conv sexplib zarith cstruct-lwt cpuid ];

  };

  mmap = osuper.mmap.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mmap/archive/41596aa.tar.gz;
      sha256 = "0fxv8qff9fsribymjgka7rq050i9yisph74nx642i5z7ng8ahlxq";
    };
  });

  notty = buildDunePackage {
    pname = "notty";
    version = "0.2.3+dev";
    src = builtins.fetchurl {
      url = https://github.com/pqwy/notty/archive/e4deddd2c72549947af4c7c6b0eae0d5eb0d74c2.tar.gz;
      sha256 = "0nr4kv3rylzx5blzhymlnd02fsmaysk45d7c882mbzr9g0blk3nb";
    };

    nativeBuildInputs = [ cppo ];
    propagatedBuildInputs = [ uucp uuseg uutf lwt ];
    strictDeps = true;
  };

  npy = osuper.npy.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
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

  jsonrpc = osuper.jsonrpc.overrideAttrs (o: {
    src =
      if lib.versionOlder "5.00" osuper.ocaml.version
      then
        builtins.fetchGit
          {
            url = "https://github.com/EduardoRFS/ocaml-lsp.git";
            submodules = true;
            ref = "500";
            rev = "24fcebcec9f1e99815b036a6d45c0f912e8e8a19";
          }
      else o.src;
  });

  lsp = osuper.lsp.overrideAttrs (o: {
    preBuild =
      if lib.versionOlder "5.00" osuper.ocaml.version then
        ''
          rm -r ocaml-lsp-server/vendor/{octavius,cmdliner}
        '' else o.preBuild;
  });

  ocaml-lsp =
    if lib.versionOlder "4.14" osuper.ocaml.version &&
      ! (lib.versionOlder "5.00" osuper.ocaml.version)
    then null
    else osuper.ocaml-lsp;

  inherit (callPackage ./ocamlformat-rpc { cmdliner = cmdliner_1_0; })
    ocamlformat-rpc# latest version
    ocamlformat-rpc_0_20_0
    ocamlformat-rpc_0_20_1;

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

  ocaml-recovery-parser = osuper.ocaml-recovery-parser.overrideAttrs (o: rec {
    version = "0.2.3";

    src = fetchFromGitHub {
      owner = "serokell";
      repo = o.pname;
      rev = version;
      sha256 = "w4NzCbaDxoM9CnoZHe8kS+dnd8n+pfWhPxQ1dDSQNHU=";
    };
  });

  ocplib_stuff = buildDunePackage {
    pname = "ocplib_stuff";
    version = "0.3.0";
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocplib_stuff/archive/refs/tags/v0.3.0.tar.gz;
      sha256 = "0r5xh2aj1mbmj6ncxzkjzadgz42gw4x0qxxqdcm2m6531pcyfpq5";
    };
  };

  ocp-build = (osuper.ocp-build.override { cmdliner = cmdliner_1_0; }).overrideDerivation (o: {
    preConfigure = "";
  });

  ocp-index = osuper.ocp-index.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocp-index/archive/a6b3a022522359a38618777c685363a750cb82d4.tar.gz;
      sha256 = "1rh1z48qj946zq2vmxrfib0p3br1p5gkpfb48rq5kz3j82sfs2jk";
    };
  });

  ocplib-endian = osuper.ocplib-endian.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocamlpro/ocplib-endian/archive/7179dd6e66.tar.gz;
      sha256 = "1rgncdbbwa5j0wx0p8n44y29mpx98v6fmy8s0djri12frlm0k5dl";
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
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];

  });

  omd = buildDunePackage {
    pname = "omd";
    version = "next";

    src = builtins.fetchurl {
      url = https://github.com/EduardoRFS/omd/archive/7b866aacbc119e2be5.tar.gz;
      sha256 = "070jm2vfrcjpshabhii87ws0nm1alirkkqj0x41rpimn4zdid00p";
    };
    propagatedBuildInputs = [ camlp-streams bigarray-compat ];
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

  ppx_cstubs = osuper.ppx_cstubs.overrideAttrs (o: {
    postPatch =
      if lib.versionOlder "4.14" osuper.ocaml.version
      then ''
        substituteInPlace "src/custom/ppx_cstubs_custom.cppo.ml" --replace \
        "(str, _sg, _sn, newenv)" \
        "(str, _sg, _sn, _shp, newenv)"
      ''
      else "";

    buildInputs = o.buildInputs ++ [ osuper.findlib ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  ppxlib = osuper.ppxlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.26.0/ppxlib-0.26.0.tbz;
      sha256 = "1zbyh6pr6fih2c1p6gs8y0q0ag1kzs41z4pyama96qsqx9kpn4b3";
    };
    patches = [
      # OCaml 5.00 support
      (fetchpatch {
        url = https://github.com/patricoferris/ppxlib/commit/91c39e958fca1dabf16f64dc7699ace7752f0014.patch;
        sha256 = "sha256-RVHA0UAJwB0DbxRrEVqtBPu8TRAxxazg3X+whyjq3Uk=";
      })
    ];
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      stdio
      stdlib-shims
    ];
  });

  postgresql =
    (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
      postPatch = ''
        substituteInPlace src/dune --replace " bigarray" ""
      '';
      nativeBuildInputs = o.nativeBuildInputs ++ [ libpq ];
    });

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    buildInputs = [ ];
    propagatedBuildInputs = [
      findlib
      ppxlib
      ppx_derivers
      result
    ];
    # Tests use `Pervasives`.
    doCheck = false;
  });

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/64c3af9.tar.gz;
      sha256 = "1xzk0z6304ivm2lfrmd7mqxnirsimbq89ds3fkh6dvjyysav2mqi";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ppx_blob = osuper.ppx_blob.overrideAttrs (_: { doCheck = false; });

  ppx_import = osuper.ppx_import.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_import/archive/0d066f04788770ff555b855538aed1663830132f.tar.gz;
      sha256 = "0fk6pn7gsif2a00mbgv4a64jg5azi5gjhp5gsy450jmhjmb5qd63";
    };
  });

  ppx_tools = callPackage ./ppx_tools { };

  printbox-text = osuper.printbox-text.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/printbox/archive/refs/tags/v0.6.tar.gz;
      sha256 = "1hr6g23b8z0p9kk1g996bzbrrziqk9b2c1za5xyzcq5g3xxqipij";
    };
    preBuild = "rm -rf ./dune";
    doCheck = false;
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  pure-splitmix = buildDunePackage rec {
    pname = "pure-splitmix";
    version = "0.3";

    src = fetchFromGitHub {
      owner = "Lysxia";
      repo = pname;
      rev = version;
      sha256 = "RUnsAB4hMV87ItCyGhc47bHGY1iOwVv9kco2HxnzqbU=";
    };
  };

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
  sedlex_2 = osuper.sedlex_2.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/sedlex/archive/refs/tags/v2.5.tar.gz;
      sha256 = "199ql06hpk3p2n1hbghl1iky8zwr7lzl8n4qf14pfp0lvgvdr62v";
    };
    preBuild = ''
      substituteInPlace src/lib/dune --replace "(libraries " "(libraries camlp-streams "
    '';

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  sendfile = callPackage ./sendfile { };

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

  tar = osuper.tar.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-tar/releases/download/v2.0.0/tar-mirage-v2.0.0.tbz;
      sha256 = "0aaazix3d6a3jjskzyilg2jwlfp54dw5mfxzkvc65xswaqgly80b";
    };
    buildInputs = [ ];
  });

  toml = osuper.toml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-toml/to.ml/archive/41172b739dff43424a12f7c1f0f64939e3660648.tar.gz;
      sha256 = "0ck5bqyly3hxdb0kqgkjjl531893r7m4bhk6i93bv1wq2y58igzq";
    };

    preConfigure = ''
      echo '(using menhir 2.1)' >> ./dune-project
    '';
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

  tyxml = osuper.tyxml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/tyxml/archive/c28e871df6db66a261ba541aa15caad314c78ddc.tar.gz;
      sha256 = "10vbg9qdmmb96vrpv65px2ipshckzn12k2z611261ii7ab2y4s2s";
    };
  });
  tyxml-jsx = callPackage ./tyxml/jsx.nix { };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { };

  # These require crowbar which is still not compatible with newer cmdliner.
  pecu = osuper.pecu.overrideAttrs (_: { doCheck = false; });
  unstrctrd = osuper.unstrctrd.overrideAttrs (_: { doCheck = false; });

  uuidm = osuper.uuidm.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/uuidm/archive/da1de441840fd457b21166448f9503fcf6dc6518.tar.gz;
      sha256 = "0vpdma904jmw42g0lav153yqzpzwlkwx8v0c8w39al8d2r4nfdb1";
    };
  });

  uucp = osuper.uucp.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ uucd ];
  });

  uunf = osuper.uunf.overrideAttrs (_: {
    buildPhase = ''
      # big enough stack size
      export OCAMLRUNPARAM="l=1100000"
      ${topkg.buildPhase}
    '';
  });

  uutf = osuper.uutf.overrideAttrs (o: {
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

  zarith = osuper.zarith.overrideAttrs (_: {
    propagatedBuildInputs = [ gmp-oc ];
  });

  bin_prot = osuper.bin_prot.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

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

  core_unix = osuper.core_unix.overrideAttrs (o: {
    # https://github.com/janestreet/core_unix/issues/2
    patches =
      if lib.versionAtLeast ocaml.version "5.00" then
        [ ./core_unix.patch ] else [ ];

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
      url = https://github.com/janestreet/memtrace/releases/download/v0.2.2/memtrace-0.2.2.tbz;
      sha256 = "13y4qh9vyz1qkg8v8gicaxcnsm992gx4zyky1ays0ddj0rh6c04m";
    };
    pname = "memtrace";
    version = "0.1.2-dev";
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
      if lib.versionAtLeast ocaml.version "5.00" then
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
      if lib.versionAtLeast ocaml.version "5.00" then
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
    patches =
      if lib.versionAtLeast ocaml.version "5.00" then
        [
          (fetchpatch {
            url = https://github.com/janestreet/base/commit/705fb94f84dfb05fd97747ee0c255cce890afcf1.patch;
            sha256 = "sha256-ByuGM+e1A7dRWPzMXxoRdBGMegkycIFK2jpguWu9wIY=";
          })
        ] else [ ];
  });

  core = osuper.core.overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.00" then
        builtins.fetchurl
          {
            url = https://github.com/janestreet/core/archive/7b556f1a7d25254f06b7aaf3c2534633be5a0a9e.tar.gz;
            sha256 = "0qpn9ks3329g1zkqs0z3cal06pi2niqr6v1gm1gp3cr3sprs31gn";
          }
      else o.src;
  });

  jst-config = osuper.jst-config.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/jst-config/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "06xlyg0cyvv742haypdjbl82b5h5mla9hhcg3q67csq1nfxyalvh";
    };
  });

  ppx_expect = osuper.ppx_expect.overrideAttrs (_: {
    patches =
      if lib.versionAtLeast ocaml.version "5.00" then
        [
          (fetchpatch {
            url = https://github.com/janestreet/ppx_expect/commit/8dd65c4ce6a8a81ebb99046ea5cc867aea187a8a.patch;
            sha256 = "sha256-NjpLOHUp2qUSIzKJNuuwNcRxR1FU5R/ugrK3m0vOnl0=";
          })
        ]
      else [ ];
  });

  ppx_sexp_conv = osuper.ppx_sexp_conv.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/ppx_sexp_conv/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "179f1iz504l008b3p3d9q2nj44wv7y31pc997x32m6aq1j2lfip3";
    };
  });

  sexp_pretty = osuper.sexp_pretty.overrideAttrs (_: {
    patches =
      if lib.versionAtLeast ocaml.version "5.00" then
        [
          (fetchpatch {
            url = https://github.com/anmonteiro/sexp_pretty/commit/4667849007831027c5887edcfae4182d7a6d32d9.patch;
            sha256 = "sha256-u4KyDiYBssIqYeyYdidTbFN9tmDeJg8y1eM5tkZKXzo";
          })
        ]
      else [ ];
  });
}
