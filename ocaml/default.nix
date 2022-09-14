{ nixpkgs
, fetchpatch
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
in

with oself;

{
  # A snapshot test is failing because of the cmdliner upgrade.
  alcotest = disableTests osuper.alcotest;

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

  bls12-381 = osuper.bls12-381.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/dannywillems/ocaml-bls12-381/archive/refs/tags/5.0.0.tar.gz;
      sha256 = "0d7zpbr0drvf5c5x3rkwdp8bx0rnkc63v6pzkdgb0xma6f5gp53k";
    };
    propagatedBuildInputs = [ ff-sig hex integers zarith ];
    doCheck = false;
  });

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
      url = https://github.com/xavierleroy/camlzip/archive/refs/tags/rel111.tar.gz;
      sha256 = "0dzdspqp9nzx8wyhclbm68dykvfj6b97c8r7b47dq4qw7vgcbfzz";
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
  });

  caqti = osuper.caqti.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-caqti/releases/download/v1.9.0/caqti-v1.9.0.tbz;
      sha256 = "1icj262f3l186j9bra0cwlpnlzzpfln7y1kl67r58fmgiy281xg1";
    };
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

  cmdliner = cmdliner_1_1;

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

    patches = [ ];

    doCheck = lib.versionAtLeast ocaml.version "5.0";
  });

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

  decompress = disableTests osuper.decompress;

  dolog = buildDunePackage {
    pname = "dolog";
    version = "6.0.0";
    src = builtins.fetchurl {
      url = https://github.com/UnixJunkie/dolog/archive/refs/tags/v6.0.0.tar.gz;
      sha256 = "0idxs1lnpsh49hvxnrkb3ijybd83phzbxfcichchw511k9ismlia";
    };
  };

  domainslib =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./domainslib { }
    else null;


  dns = osuper.dns.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-dns/releases/download/v6.3.0/dns-6.3.0.tbz;
      sha256 = "0lbk61ca8yxhf6dl8v1i5rlw6hwqmwvn9hn57sw8h43xfdx26h6w";
    };

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ base64 ];
  });
  dns-resolver = osuper.dns-resolver.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ dnssec ];
  });
  dns-cli = osuper.dns-cli.overrideAttrs (o: {
    propagatedBuildInputs = o.buildInputs ++ [ dnssec ];
  });
  dnssec = buildDunePackage {
    pname = "dnssec";
    inherit (dns) version src;
    propagatedBuildInputs = [
      cstruct
      dns
      mirage-crypto
      mirage-crypto-pk
      mirage-crypto-ec
      domain-name
      base64
      logs
    ];
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
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
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
    patches = [ ];
  });

  eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio { }
    else null;
  eio_linux =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio/linux.nix { }
    else null;
  eio_luv =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio/luv.nix { }
    else null;
  eio_main =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio/main.nix { } else null;

  eio-ssl =
    if lib.versionAtLeast ocaml.version "5.0" then
      buildDunePackage
        {
          pname = "eio-ssl";
          version = "n/a";
          src = builtins.fetchurl {
            url = https://github.com/anmonteiro/eio-ssl/archive/4e3d2d2.tar.gz;
            sha256 = "0whaqs2ypx18q6084vz0vvwz85dxmya9c7ycwxqm8z1lx65a8j1w";
          };
          propagatedBuildInputs = [ ssl eio_main ];
        } else null;

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
      url = https://github.com/ocaml/ocamlfind/archive/refs/tags/findlib-1.9.5.tar.gz;
      sha256 = "1dydivj0fs1snxss47fi84kgk1bf2cfbwgwv7j4lrzlr0xqli3xa";
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

  gen_js_api = disableTests osuper.gen_js_api;

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
  gluten-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./gluten/eio.nix { }
    else null;

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
  # callPackage ./happy-eyeballs { };
  happy-eyeballs-lwt = callPackage ./happy-eyeballs/lwt.nix { };
  happy-eyeballs-mirage = callPackage ./happy-eyeballs/mirage.nix { };

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  h2-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./h2/eio.nix { }
    else null;
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
  httpaf-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./httpaf/eio.nix { }
    else null;

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
  # https://github.com/mirage/metrics/issues/57
  irmin-test = null;

  iter = osuper.iter.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/iter/archive/a3b34263.tar.gz;
      sha256 = "0jfb7aw1fv2y5skcv0gc74j37fy2k22j87fqs6fjhpw0dw2si0lr";
    };

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ seq ];
    # MDX has some broken python transitive deps
    doCheck = false;
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

  lockfree =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./lockfree { }
    else null;

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

  luv_unix = buildDunePackage {
    pname = "luv_unix";
    inherit (luv) version src;
    propagatedBuildInputs = [ luv ];
  };

  lwt = osuper.lwt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ bigarray-compat ];
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config cppo ];

    postPatch = ''
      substituteInPlace src/core/dune --replace "(libraries bytes)" ""
      substituteInPlace src/unix/dune --replace "bigarray" ""
    '';

    src = builtins.fetchurl {
      url = https://github.com/ocsigen/lwt/archive/refs/tags/5.6.1.tar.gz;
      sha256 = "1837iagnba58018ag82c9lwaby01c031547n08jjyj8q5q6lfjgb";
    };
  });

  lwt-watcher = osuper.lwt-watcher.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/70f826c503cc094ed2de3aa81fa385ea9fddb903.tar.gz;
      sha256 = "0q1qdmagldhwrcqiinsfag6zxcn5wbvn2p10wpyi8rgk27q3l8sk";
    };
  });

  lwt_domain =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./lwt/domain.nix { }
    else null;
  lwt_react = callPackage ./lwt/react.nix { };

  lwt_eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio/lwt_eio.nix { }
    else null;

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

  ocp-indent = osuper.ocp-indent.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "libraries bytes" "libraries "
    '';
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ocp-index = osuper.ocp-index.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocp-index/archive/a6b3a022522359a38618777c685363a750cb82d4.tar.gz;
      sha256 = "1rh1z48qj946zq2vmxrfib0p3br1p5gkpfb48rq5kz3j82sfs2jk";
    };
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

  parmap = disableTests osuper.parmap;

  pg_query = callPackage ./pg_query { };

  piaf =
    if lib.versionAtLeast ocaml.version "5.0"
    then callPackage ./piaf { }
    else null;
  piaf-lwt = callPackage ./piaf/lwt.nix { };
  carl =
    if lib.versionAtLeast ocaml.version "5.0"
    then callPackage ./piaf/carl.nix { }
    else null;

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
      url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.27.0/ppxlib-0.27.0.tbz;
      sha256 = "0qlcnb2aas6h69zgjbygjhmw9gvna4iwa3hfh9rnmzbg3l99cjvn";
    };
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      stdio
      stdlib-shims
    ];
  });

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

  ppx_deriving_cmdliner = osuper.ppx_deriving_cmdliner.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/hammerlab/ppx_deriving_cmdliner/archive/bc06e6c3ad161df66f46f731f97142ae5358e633.tar.gz;
      sha256 = "0xzj36vzzch6hc5zh1crjarwbmfycd61vh894v2jyai15zspf780";
    };
  });

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/69671f7.tar.gz;
      sha256 = "1i5g5ssazjb08f26r44vwjlnhca22zvy5awpxfz8g77an0vpp3p4";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ppx_blob = disableTests osuper.ppx_blob;

  ppx_import = osuper.ppx_import.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_import/archive/0d066f04788770ff555b855538aed1663830132f.tar.gz;
      sha256 = "0fk6pn7gsif2a00mbgv4a64jg5azi5gjhp5gsy450jmhjmb5qd63";
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

  reason-native = osuper.reason-native.overrideScope' (rself: rsuper: {
    rely = rsuper.rely.overrideAttrs (_: {
      postPatch = ''
        substituteInPlace "src/rely/TestSuiteRunner.re" --replace "Pervasives." "Stdlib."
      '';
    });
    qcheck-rely = null;
  });

  react = osuper.react.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/react/archive/aebf35179964e73a7ef557c6a56175c7abdb9947.tar.gz;
      sha256 = "04rqmigdbgah4yvdjpk3ai9j7d3zhp2hz2qd482p1q2k3bbn52kh";
    };
  });

  reactivedata = osuper.reactivedata.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "src/reactiveData.ml" --replace "Pervasives." "Stdlib."
    '';
  });


  # Tests use `String.capitalize` which was removed in 5.0
  re = disableTests osuper.re;

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
    propagatedBuildInputs = [ ctypes libsodium ];
  };

  ssl = osuper.ssl.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl-oc.dev ];
  });

  stdint = osuper.stdint.overrideAttrs (_: {
    patches = [ ];
    src = builtins.fetchurl {
      url = https://github.com/andrenth/ocaml-stdint/archive/322a8a4a8c69e4a0b75763460b915200356e3af3.tar.gz;
      sha256 = "0ljm6f3vpcvssh9svd696l1b5s42z4a7gcrdqc6yvdakycmwbyqi";
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
  pecu = disableTests osuper.pecu;
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
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/uuidm/archive/da1de441840fd457b21166448f9503fcf6dc6518.tar.gz;
      sha256 = "0vpdma904jmw42g0lav153yqzpzwlkwx8v0c8w39al8d2r4nfdb1";
    };
    postPatch = ''
      substituteInPlace pkg/META --replace "bytes" ""
    '';
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

  yuscii = disableTests osuper.yuscii;

  zarith = osuper.zarith.overrideAttrs (_: {
    propagatedBuildInputs = [ gmp-oc ];
  });

  zed = osuper.zed.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/zed/releases/download/3.2.0/zed-3.2.0.tbz;
      sha256 = "0gji5rp44mqsld117n8g93cqg8302py1piqshmvg63268fylj8rl";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ uuseg uutf ];
  });

  bin_prot = osuper.bin_prot.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  bonsai = osuper.bonsai.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ patdiff ];
  });
  patdiff = janePackage {
    pname = "patdiff";
    hash = "0623a7n5r659rkxbp96g361mvxkcgc6x9lcbkm3glnppplk5kxr9";
    propagatedBuildInputs = [ core_unix patience_diff ocaml_pcre ];
    meta = {
      description = "File Diff using the Patience Diff algorithm";
    };
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

  async_ssl = osuper.async_ssl.overrideAttrs (_: {
    propagatedBuildInputs = [ async ctypes openssl-oc.dev ctypes-foreign ];
    postPatch = ''
      substituteInPlace "bindings/dune" --replace "ctypes.foreign" "ctypes-foreign"
    '';
  });

  cohttp = osuper.cohttp.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./cohttp/src/dune --replace "bytes" ""
    '';
  });

  core_unix = osuper.core_unix.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/core_unix/archive/65a25ec0.tar.gz;
      sha256 = "1fr223k0bwpmavqr7glj1ljs3ybgg6j4mvs53d7kcj7kc1ngz0rm";
    };
    # https://github.com/janestreet/core_unix/issues/2
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
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

    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
        [ ./memtrace_5_00.patch ]
      else
        [ ];
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
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
        [
          (fetchpatch {
            url = https://github.com/janestreet/base/commit/705fb94f84dfb05fd97747ee0c255cce890afcf1.patch;
            sha256 = "sha256-ByuGM+e1A7dRWPzMXxoRdBGMegkycIFK2jpguWu9wIY=";
          })
        ] else [ ];
  });

  core = osuper.core.overrideAttrs (o: {
    src =
      if lib.versionAtLeast ocaml.version "5.0" then
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

    patches = [ ];
  });

  ppx_expect = osuper.ppx_expect.overrideAttrs (_: {
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
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
      url = https://github.com/janestreet/ppx_yojson_conv/archive/ea556c6.tar.gz;
      sha256 = "0r4sd781ff1bjpw9hwim4i4q3sp30w3x4gz854mz596w5d1cl1xk";
    };
  });

  sexp_pretty = osuper.sexp_pretty.overrideAttrs (_: {
    patches =
      if lib.versionAtLeast ocaml.version "5.0" then
        [
          (fetchpatch {
            url = https://github.com/anmonteiro/sexp_pretty/commit/4667849007831027c5887edcfae4182d7a6d32d9.patch;
            sha256 = "sha256-u4KyDiYBssIqYeyYdidTbFN9tmDeJg8y1eM5tkZKXzo";
          })
        ]
      else [ ];
  });

  incr_dom = osuper.incr_dom.overrideAttrs (_: {
    patches = [
      "${nixpkgs}/pkgs/development/ocaml-modules/janestreet/incr_dom_jsoo_4_0.patch"
    ];
  });
}
