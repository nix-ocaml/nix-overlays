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
, unzip
, freetype
, fontconfig
, libxkbcommon
, libxcb
, xorg
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
  alcotest = osuper.alcotest.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/alcotest/releases/download/1.7.0/alcotest-1.7.0.tbz;
      sha256 = "1pq2g5k427sx3mzn75hrxxwj9xxjv9mk1mq7bscqhpml6kdsqaw1";
    };
  });

  ansiterminal = osuper.ansiterminal.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace " bytes" ""
    '';
  });

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
    src = fetchFromGitHub {
      owner = "crackcomm";
      repo = "ocaml-multiformats";
      rev = "380208ded45bc33cfadc5de6709846b3a8b84615";
      sha256 = "sha256-OuGBf8LdoiuC9OkTObwP5sgT6LXVtdTCsPbg8T1OHt8=";
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

  bencode = buildDunePackage {
    pname = "bencode";
    version = "2.0";
    src = fetchFromGitHub {
      owner = "rgrinberg";
      repo = "bencode";
      rev = "2.0";
      sha256 = "sha256-sEMS9oBOPeFX1x7cHjbQhCD2QI5yqC+550pPqqMsVws=";
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

  binaryen = callPackage ./binaryen { };

  bisect_ppx = osuper.bisect_ppx.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ ppxlib cmdliner ];
  });

  bls12-381 = disableTests osuper.bls12-381;

  bls12-381-legacy = osuper.bls12-381-legacy.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./src/legacy/dune --replace "libraries " "libraries ctypes.stubs "
    '';
  });

  bos = osuper.bos.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "bos";
      rev = "v0.2.1";
      sha256 = "sha256-ga7CwQpXntW0wg6tP9/c16wfSGEf07DfZdd7b6cp0r0=";
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
    src = fetchFromGitHub {
      owner = "xavierleroy";
      repo = "camlzip";
      rev = "3b0e0a5f7";
      sha256 = "sha256-DflyuI2gt8HQI8qAgczClVdLy21uXT1A9VMD5cTaDl4=";
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

  checkseum = osuper.checkseum.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/checkseum/releases/download/v0.5.0/checkseum-0.5.0.tbz;
      sha256 = "0bnyzxvagc4cvpz0a434xngk9ra1mjjh67nhyv3qz5ghk5s6a5bv";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script ];
  });

  coin = osuper.coin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/coin/releases/download/v0.1.4/coin-0.1.4.tbz;
      sha256 = "0069qqswd1ik5ay3d5q1v1pz0ql31kblfsnv0ax0z8jwvacp3ack";
    };
  });

  cairo2 = osuper.cairo2.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bigarray" ""
    '';
  });

  cairo2-gtk = buildDunePackage {
    pname = "cairo2-gtk";
    inherit (cairo2) version src;
    nativeBuildInputs = [ nativeCairo pkg-config ];
    buildInputs = [ dune-configurator gtk2.dev ];
    propagatedBuildInputs = [ cairo2 lablgtk ];
  };

  cpdf = osuper.cpdf.overrideAttrs (_: {
    cpdf = osuper.cpdf.overrideAttrs (_: {
      src = fetchFromGitHub {
        owner = "johnwhitington";
        repo = "cpdf-source";
        rev = "d00f857";
        hash = "sha256-63G6VZwMGqckaiKBFaj7rErKNEMdtKsXCzGn1hwSWI0=";
      };
    });
  });

  camlpdf = osuper.camlpdf.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "johnwhitington";
      repo = "camlpdf";
      rev = "abadaea";
      hash = "sha256-yagJJy90fOyj2uHc36G1BJrIrt0N7nSYGx4DkTrGkRg=";
    };
  });

  carton = disableTests osuper.carton;

  caqti = osuper.caqti.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "paurkedal";
      repo = "ocaml-caqti";
      rev = "eca8ecb";
      sha256 = "sha256-W+lc1vU7QQt97N383KP4RUJ7eIPtS4gPT32IpOVGM3s=";
    };

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ipaddr ];
  });

  caqti-async = osuper.caqti-async.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ conduit-async ];
  });

  caqti-dynload = osuper.caqti-dynload.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ findlib ];
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

  colombe = buildDunePackage {
    pname = "colombe";
    version = "0.5.2";
    src = builtins.fetchurl {
      url = https://github.com/mirage/colombe/releases/download/v0.8.0/colombe-0.8.0.tbz;
      sha256 = "1wzzwxdixv672py2fs419n92chjyq7703zzrgya6bxvsbffx6flx";
    };
    propagatedBuildInputs = [ ipaddr fmt angstrom emile ];
  };
  sendmail = buildDunePackage {
    pname = "sendmail";
    inherit (colombe) version src;
    propagatedBuildInputs = [ colombe tls ke rresult base64 ];
  };
  sendmail-lwt = buildDunePackage {
    pname = "sendmail-lwt";
    inherit (colombe) version src;
    propagatedBuildInputs = [ sendmail lwt tls-lwt ];
  };

  received = buildDunePackage {
    pname = "received";
    version = "0.5.2";
    src = builtins.fetchurl {
      url = https://github.com/mirage/colombe/releases/download/received-v0.5.2/colombe-received-v0.5.2.tbz;
      sha256 = "1gig5kpkp9rfgnvkrgm7n89vdrkjkbbzpd7xcf90dja8mkn7d606";
    };
    propagatedBuildInputs = [ angstrom emile mrmime colombe ];
  };

  conan = callPackage ./conan { };
  conan-lwt = callPackage ./conan/lwt.nix { };
  conan-unix = callPackage ./conan/unix.nix { };
  conan-database = callPackage ./conan/database.nix { };
  conan-cli = callPackage ./conan/cli.nix { };

  conduit = osuper.conduit.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "ocaml-conduit";
      rev = "403b4cec528dae71aded311215868a35c11dad7e";
      hash = "sha256-1dEjC/y1rP8LBGIYSE1HB66Q2fX722sHxJpDwQS+A3Q=";
    };
  });
  conduit-mirage = osuper.conduit-mirage.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ dns-client-mirage ];
  });

  confero =
    let
      allkeys_txt = builtins.fetchurl {
        url = https://www.unicode.org/Public/UCA/15.0.0/allkeys.txt;
        sha256 = "0xvmfw9sgcmaqs33w31vcmgqabkb2ls146pb9hvidbfl4isj49qq";
      };
      collationTest = builtins.fetchurl {
        url = https://www.unicode.org/Public/UCA/15.0.0/CollationTest.zip;
        sha256 = "013w1s3nwalyid9n092my9ri1j0kzc35bphzbrdcaz6l22ph81f3";
      };
    in
    buildDunePackage {
      pname = "confero";
      version = "0.1.1";
      src = fetchFromGitHub {
        owner = "paurkedal";
        repo = "confero";
        rev = "252cf3e";
        sha256 = "sha256-YJyyT4uimLJQH0/bIMe/FCPk0ZYemgHYxV4uaQXVE6w=";
      };

      nativeBuildInputs = [ unzip ];
      postPatch = ''
        cp ${allkeys_txt} ./lib/ducet/allkeys.txt
        cp ${collationTest} ./test/CollationTest.zip
      '';

      doCheck = true;

      propagatedBuildInputs = [
        angstrom
        angstrom-unix
        cmdliner
        fmt
        iso639
        uucp
        uunf
        uutf
      ];
    };

  cookie = callPackage ./cookie { };
  session-cookie = callPackage ./cookie/session.nix { };
  session-cookie-lwt = callPackage ./cookie/session-lwt.nix { };

  # Not available for 4.12 and breaking the static build
  cooltt = null;

  cry = osuper.cry.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bytes" ""
    '';
  });

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

  csv = osuper.csv.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bytes" ""
    '';
  });
  csv-lwt = osuper.csv-lwt.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lwt/dune --replace "bytes" ""
    '';
  });

  ctypes = buildDunePackage rec {
    pname = "ctypes";
    version = "0.20.1";
    src = fetchFromGitHub {
      owner = "ocamllabs";
      repo = "ocaml-ctypes";
      rev = "64b6494d0";
      sha256 = "sha256-YMaKJK8gqsUdYglB4xGdMUpTXbgUgZLLvUG/lSvJesE=";
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

    propagatedBuildInputs = [ extlib ];

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
    src = fetchFromGitHub {
      owner = "mattjbray";
      repo = "ocaml-decoders";
      rev = "00d930";
      sha256 = "sha256-LK2CZHvs9itx51EVi/MonrvnGOlPtLDXdMhAFX9O8Uc=";
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
    src = fetchFromGitHub {
      owner = "UnixJunkie";
      repo = "dolog";
      rev = "v6.0.0";
      sha256 = "sha256-g68260mcb4G4wX8y4T0MTaXsYnM9wn2d0V1VCdSFZjY=";
    };
  };

  domain_shims = buildDunePackage {
    pname = "domain_shims";
    version = "0.1.0";

    src = builtins.fetchurl {
      url = https://gitlab.com/gasche/domain-shims/-/archive/0.1.0/domain-shims-0.1.0.tar.gz;
      sha256 = "0cad63qyfzn0nhf8b80yaw974q4zy1jahwd44rmaawpsj4ap2rq8";
    };
  };

  dream-pure = callPackage ./dream/pure.nix { };
  dream-httpaf = callPackage ./dream/httpaf.nix { };
  dream = callPackage ./dream { };

  dream-livereload = callPackage ./dream-livereload { };

  dream-serve = callPackage ./dream-serve { };

  dtoa = osuper.dtoa.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/flow/ocaml-dtoa/releases/download/v0.3.3/dtoa-0.3.3.tbz;
      sha256 = "0gpfr6iyiihmkpas542916cnhfdbrigvzwrix8jrxcljks661x6q";
    };
  });

  dum = osuper.dum.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "dum.ml" --replace "Lazy.lazy_is_val" "Lazy.is_val"
      substituteInPlace "dum.ml" --replace "Obj.final_tag" "Obj.custom_tag"
    '';
  });

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

  dune_2 = dune_3;

  dune_3 = osuper.dune_3.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "dune";
      rev = "649031728346482a83441c26c0bbe06ecd89cce2";
      hash = "sha256-IbvAumstRp7JE+UQDArrwYWyZtbe8q8bZo05eVzA/MU=";
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

  dune-build-info = osuper.dune-build-info.overrideAttrs (_: {
    propagatedBuildInputs = [ pp ];
    inherit (dyn) preBuild;
  });
  dune-configurator = osuper.dune-configurator.overrideAttrs (_: {
    inherit (dyn) preBuild;
  });
  ordering = osuper.ordering.overrideAttrs (_: {
    inherit (dyn) preBuild;
  });
  dune-rpc = osuper.dune-rpc.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ stdune ordering pp xdg dyn ];
    inherit (dyn) preBuild;
  });
  dune-rpc-lwt = callPackage ./dune/rpc-lwt.nix { };
  dyn = osuper.dyn.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    preBuild = "rm -rf vendor/csexp vendor/pp";
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
    src = fetchFromGitHub {
      owner = "ocaml-dune";
      repo = "fiber";
      rev = "a7b5456b95a67099c5f8078d7098e565e4d5b9ea";
      sha256 = "sha256-nnvQU9Kk63BQqQiAhzPVLnjnEpKBSxjcfTn31RfiMoU=";
    };
    propagatedBuildInputs = [ dyn stdune ];
    preBuild = "";
  });
  fiber-lwt = buildDunePackage {
    pname = "fiber-lwt";
    inherit (fiber) version src;
    propagatedBuildInputs = [ pp fiber lwt stdune ];
  };
  stdune = osuper.stdune.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  xdg = osuper.xdg.overrideAttrs (o: {
    inherit (dyn) preBuild;
  });


  dune-release = osuper.dune-release.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocamllabs";
      repo = "dune-release";
      rev = "ab37686";
      sha256 = "sha256-x94XNMdHbSrubcmYLMXor7OLY/c2LyRiq/Ot/IHYjxM=";
    };
    doCheck = false;
  });

  ezgzip = buildDunePackage rec {
    pname = "ezgzip";
    version = "0.2.3";
    src = fetchFromGitHub {
      owner = "hcarty";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-OQ4JT1pYkeJbi8iMGpcFp8j0DawZCguFfWQmJCwgUXQ=";
    };

    propagatedBuildInputs = [ rresult astring ocplib-endian camlzip result ];
  };

  facile = osuper.facile.overrideAttrs (_: {
    postPatch = "echo '(lang dune 2.0)' > dune-project";
  });

  faraday-async = osuper.faraday-async.overrideAttrs (_: {
    patches = [ ];
  });

  ffmpeg-avdevice = osuper.ffmpeg-avdevice.overrideAttrs (o: {
    propagatedBuildInputs =
      o.propagatedBuildInputs ++
      lib.optionals stdenv.isDarwin
        (with darwin.apple_sdk.frameworks; [ AVFoundation ]);
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

  functoria-runtime = osuper.functoria-runtime.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./lib_runtime/functoria/dune --replace "bytes" ""
    '';
  });

  gen = osuper.gen.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bytes seq" "seq"
    '';
  });

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
    src = fetchFromGitHub {
      owner = "mmottl";
      repo = "gsl-ocaml";
      rev = "76f8d93cc";
      sha256 = "sha256-+xAZm1K1iriZn5sxk8CmzzK1Bd7K4kXROqriGHo3rOs=";
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

  iomux = buildDunePackage {
    pname = "iomux";
    version = "0.2";
    src = builtins.fetchurl {
      url = https://github.com/haesbaert/ocaml-iomux/releases/download/v0.2/iomux-0.2.tbz;
      sha256 = "10b1gl9fq7nk4j9bbpvbmk627cflnw51f4s2gbjh4jddkcgs7bfj";
    };
    hardeningDisable = [ "strictoverflow" ];
    buildInputs = [ lmdb-pkg dune-configurator ];
  };

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  irmin = osuper.irmin.override { mtime = mtime_1; };
  irmin-chunk = disableTests osuper.irmin-chunk;
  irmin-containers = osuper.irmin-containers.override { mtime = mtime_1; };
  irmin-fs = disableTests osuper.irmin-fs;
  irmin-pack = disableTests (osuper.irmin-pack.override { mtime = mtime_1; });
  irmin-git = disableTests osuper.irmin-git;
  irmin-http = osuper.irmin-http.overrideAttrs (_: {
    dontDetectOcamlConflicts = true;
    doCheck = false;
  });
  irmin-tezos = disableTests osuper.irmin-tezos;
  # https://github.com/mirage/metrics/issues/57
  irmin-test = null;

  iso639 = buildDunePackage {
    pname = "iso639";
    version = "0.0.5";
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-iso639/releases/download/v0.0.5/iso639-v0.0.5.tbz;
      sha256 = "11bk38m5wsh3g4pr1px3865w8p42n0cq401pnrgpgyl25zdfamk0";
    };
  };

  iter = osuper.iter.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "bytes" ""
    '';
  });

  qcheck-alcotest = osuper.qcheck-alcotest.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/alcotest/dune --replace "bytes" ""
    '';
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

  index = osuper.index.override { mtime = mtime_1; };

  itv-tree = buildDunePackage {
    pname = "itv-tree";
    version = "2.2";
    src = fetchFromGitHub {
      owner = "UnixJunkie";
      repo = "interval-tree";
      rev = "v2.2";
      sha256 = "sha256-jt8JnY5l9uW5Epjv1ZqGDiLEFU4HHsebcCIS7n6gh6M=";
    };

    propagatedBuildInputs = [ camlp-streams ];
  };

  javalib = osuper.javalib.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/ptrees/ptset.ml --replace "Pervasives." "Stdlib."
      substituteInPlace ./src/jFile.ml --replace "Pervasives." "Stdlib."
    '';

  });

  jose = callPackage ./jose { };

  jsonm = osuper.jsonm.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "jsonm";
      rev = "v1.0.2";
      hash = "sha256-txBRq5I3336gQcu2CXAQsqfPtB1qw4P69G5Up60PQdQ=";
    };
  });

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

  kafka = osuper.kafka.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "didier-wenzek";
      repo = "ocaml-kafka";
      rev = "2f607bcf";
      sha256 = "sha256-lW2Eu1mneZ+2XyJvbu5mkrgUsQ8a66Gi+/T8wDM0FcM=";
    };
    hardeningDisable = [ "strictoverflow" ];
  });
  kafka_async = buildDunePackage {
    pname = "kafka_async";
    inherit (kafka) src version;
    propagatedBuildInputs = [ async kafka ];
    hardeningDisable = [ "strictoverflow" ];
  };
  kafka_lwt = osuper.kafka_lwt.overrideAttrs (_: {
    hardeningDisable = [ "strictoverflow" ];
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

  lev = buildDunePackage {
    pname = "lev";
    version = "n/a";
    src = fetchFromGitHub {
      "owner" = "rgrinberg";
      repo = "lev";
      rev = "2c98545efbc2a485b836294627ad78ca9f562c7d";
      hash = "sha256-kvQIV/b0rlnCmJtQJeqhEsfEQfWS7XWwKGhMYxKHFL8=";
    };
    buildInputs = [ libev-oc ];
  };
  lev-fiber =
    if lib.versionAtLeast osuper.ocaml.version "4.14" then
      buildDunePackage
        {
          pname = "lev-fiber";
          inherit (lev) version src;
          propagatedBuildInputs = [ lev dyn fiber stdune ];
          checkInputs = [ ppx_expect ];
        } else null;
  lev-fiber-csexp =
    if lib.versionAtLeast osuper.ocaml.version "4.14" then
      buildDunePackage
        {
          pname = "lev-fiber";
          inherit (lev) version src;
          propagatedBuildInputs = [ lev-fiber csexp ];
        } else null;

  digestif = osuper.digestif.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });

  lmdb = buildDunePackage {
    pname = "lmdb";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "Drup";
      repo = "ocaml-lmdb";
      rev = "1.0";
      sha256 = "sha256-NbiM7xNpuihzqAMiAaYXVeItspWufnr1/e3WZEkMhsA=";
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
    src = fetchFromGitHub {
      owner = "ocsigen";
      repo = "lwt";
      rev = "3d6f0fac";
      sha256 = "sha256-QIxKQEoA5EOGqhwCKdIWQ09RhPKYoleTWdbT1GI397o=";
    };

    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config cppo ];
    propagatedBuildInputs = [ libev-oc ocplib-endian ];

    postPatch = ''
      substituteInPlace src/unix/dune --replace "bigarray" ""
    '';
  });

  lwt_ssl = osuper.lwt_ssl.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocsigen";
      repo = "lwt_ssl";
      rev = "1.2.0";
      sha256 = "sha256-LkmS+vmnX3Oa9qnVN4cFzRSHP6ep/VgZmeWksmo2tDY=";
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
  mirage-crypto = osuper.mirage-crypto.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });
  mirage-crypto-ec = osuper.mirage-crypto-ec.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });
  mirage-crypto-pk = osuper.mirage-crypto-pk.override { gmp = gmp-oc; };

  # `mirage-fs` needs to be updated to match `mirage-kv`'s new interface
  #   mirage-kv = osuper.mirage-kv.overrideAttrs (_: {
  # src = builtins.fetchurl {
  # url = https://github.com/mirage/mirage-kv/releases/download/v6.1.0/mirage-kv-6.1.0.tbz;
  # sha256 = "0i6faba2nrm2ayq8f6dvgvcv53b811k77ibi7jp4138jpj2nh4si";
  # };
  # propagatedBuildInputs = [ fmt optint lwt ptime ];
  #   });

  # mirage-kv-mem = buildDunePackage {
  # pname = "mirage-kv-mem";
  # version = "3.2.1";
  # src = builtins.fetchurl {
  # url = https://github.com/mirage/mirage-kv-mem/releases/download/v3.2.1/mirage-kv-mem-3.2.1.tbz;
  # sha256 = "07qr508kb4v9acybncz395p0mnlakib3r8wx5gk7sxdxhmic1z59";
  # };
  # propagatedBuildInputs = [ optint mirage-kv fmt ptime mirage-clock ];
  # };

  mustache = osuper.mustache.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "rgrinberg";
      repo = "ocaml-mustache";
      rev = "d0c45499f9a5ee91c38cf605ae20ecee47142fd8";
      sha256 = "sha256-TOgN4dhI7yjP4cm7q/yvVOtauXMnKOCdMjAgVNzNvSA=";
    };

    doCheck = false;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ cmdliner ];
    postPatch = ''
      rm -rf bin/dune
      rm -rf bin/mustache_cli.ml
    '';
  });

  logs = (osuper.logs.override { jsooSupport = false; }).overrideAttrs (_: {
    pname = "logs";
  });

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
    src = fetchFromGitHub {
      owner = "thierry-martinez";
      repo = "metapp";
      rev = "v0.4.4";
      sha256 = "sha256-lRE6Zh1oDnPOI8GqWO4g6qiS2j43NOHmckgmJ8uoHfE=";
    };
    propagatedBuildInputs = [ ppxlib stdcompat findlib ];
  };

  metrics = osuper.metrics.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "metrics";
      rev = "995eb18d";
      sha256 = "sha256-edG8L9PMjZNJlcwKBdJ54NT6mm3z1j12nAzOC9VUtJI=";
    };
  });
  metrics-unix = osuper.metrics-unix.overrideAttrs (_: {
    postPatch = null;
  });

  mongo = callPackage ./mongo { };
  mongo-lwt = callPackage ./mongo/lwt.nix { };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { };
  bson = callPackage ./mongo/bson.nix { };

  mimic-happy-eyeballs = buildDunePackage {
    pname = "mimic-happy-eyeballs";
    inherit (mimic) version src;
    propagatedBuildInputs = [ mimic happy-eyeballs-mirage ];
  };

  mrmime = osuper.mrmime.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mrmime/releases/download/v0.6.0/mrmime-0.6.0.tbz;
      sha256 = "1349cnk9cp3xnlmgdvr31lsp177a8nmcc5cky2hvjdzf9zgqjvh5";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];

    # https://github.com/mirage/mrmime/issues/91
    doCheck = !lib.versionAtLeast ocaml.version "5.0";
  });

  mtime_1 = osuper.mtime;

  mtime = osuper.mtime.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "mtime";
      rev = "v2.0.0";
      sha256 = "sha256-R1kujDbLJZbyyk91qNYAxpwdfnBUHm80zUeJ6GZeaTk=";
    };
  });

  multipart_form = callPackage ./multipart_form { };
  multipart_form-lwt = callPackage ./multipart_form/lwt.nix { };

  mmap = osuper.mmap.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "mmap";
      rev = "41596aa";
      sha256 = "sha256-3sx0Wy8XMiW3gpnEo6s2ENP/X1dSSC6NE9SrJex84Kk=";
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
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "num";
      rev = "703e1f88";
      sha256 = "sha256-Ddo6zmCPF730EV0YliIRnZ80j9YnBOH1yCQTBs7lXDo=";
    };

    patches = [ ./num/findlib-install.patch ];
  });

  ocaml = (osuper.ocaml.override { flambdaSupport = true; }).overrideAttrs (_: {
    enableParallelBuilding = true;
  });
  ocaml-version = osuper.ocaml-version.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocurrent/ocaml-version/releases/download/v3.6.1/ocaml-version-3.6.1.tbz;
      sha256 = "0clxf5nlf6qjqsharrbgavrci33cqd0bbxa4p1y7a9x18xfrm800";
    };
  });

  ocamlformat = callPackage ./ocamlformat { };
  ocamlformat-lib = callPackage ./ocamlformat/lib.nix { };
  ocamlformat-rpc-lib = callPackage ./ocamlformat/rpc-lib.nix { };

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
  });

  odep = buildDunePackage {
    pname = "odep";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "sim642";
      repo = "odep";
      rev = "0.1.0";
      sha256 = "sha256-PAnzKWOZ/4jvSWVNlvZIi5MycqjTxsC2hG27PYXAhDY=";
    };
    propagatedBuildInputs = [
      bos
      opam-state
      parsexp
      ppx_deriving
      sexplib
      ppx_sexp_conv
    ];
  };

  ez_subst = buildDunePackage {
    pname = "ez_subst";
    version = "0.2.1";
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ez_subst";
      rev = "v0.2.1";
      sha256 = "sha256-d0+H9dxLioa9QHnf2mF+MBk563qxc7YBhpmV1A0uv0s=";
    };
  };

  ez_cmdliner = buildDunePackage {
    pname = "ez_cmdliner";
    version = "0.4.3";
    src = fetchFromGitHub {
      owner = "OcamlPro";
      repo = "ez_cmdliner";
      rev = "v0.4.3";
      sha256 = "sha256-l1JQrMxZsk+CuTDNmoKvzDO/8kGJOY3C8WGetprgR1M=";
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

  ocaml-canvas = buildDunePackage {
    pname = "ocaml-canvas";
    version = "n/a";
    hardeningDisable = [ "strictoverflow" ];
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ocaml-canvas";
      rev = "962dedd98";
      sha256 = "sha256-PghULCfekMhs88a2F+RJtJFoBJxi80ieDiKzhWukJw4=";
    };

    buildInputs = lib.optionals (! stdenv.isDarwin) [
      freetype
      fontconfig
      libxkbcommon
      libxcb
      xorg.xcbutilkeysyms
      xorg.xcbutilimage
    ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      AppKit
      Foundation
      Carbon
      Cocoa
      CoreGraphics
    ]);

    propagatedBuildInputs = [ dune-configurator react ];
  };

  ocaml-recovery-parser = osuper.ocaml-recovery-parser.overrideAttrs (o: rec {
    postPatch = ''
      substituteInPlace "menhir-recover/emitter.ml" --replace \
        "String.capitalize" "String.capitalize_ascii"
    '';
  });

  ocplib_stuff = buildDunePackage {
    pname = "ocplib_stuff";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ocplib_stuff";
      rev = "v0.3.0";
      sha256 = "sha256-Wd9l1pBKaBFMzKaqSBT9mx5oHIQiXd1xB9enov2JWN8=";
    };

    # `String.sub Sys.ocaml_version 0 6` doesn't work on OCaml 5.0
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace ./src/ocplib_stuff/dune \
          --replace "failwith \"Wrong ocaml version\"" "\"5.0.0\""
      '' else "";
  };

  ocp-indent = osuper.ocp-indent.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "libraries bytes" "libraries "
    '';
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ocplib-endian = osuper.ocplib-endian.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ocplib-endian";
      rev = "fda4d5525";
      sha256 = "sha256-EoiMaiQobxtDGHRKL/GYXhM2aNVAvrBdYdgGv82LGyw=";
    };
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
    src = fetchFromGitHub {
      owner = "ocsigen";
      repo = "ocsigen-toolkit";
      rev = "499e8260df6487ebdacb9fcccb2f9dec36df8063";
      sha256 = "sha256-h1+D0HiCdEOBez+9EyqkF63TRW7pWkoUJYkugBTywI4=";
    };
  });

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

  otfm = osuper.otfm.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/otfm.ml --replace "Pervasives." "Stdlib."
    '';
  });

  eigen = osuper.eigen.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/owlbarn/eigen/releases/download/0.3.3/eigen-0.3.3.tbz;
      sha256 = "1kiy0pg0a5cnf9zff0137lfgbk7nbs5yc9dimwqdr5lihbi88cd9";
    };
    buildInputs = [ dune-configurator ];
    meta.platforms = lib.platforms.all;
    postPatch = ''
      substituteInPlace "eigen/configure/configure.ml" --replace '-mcpu=apple-m1' ""
      substituteInPlace "eigen_cpp/configure/configure.ml" --replace '-mcpu=apple-m1' ""
    '';
  });
  owl-base = osuper.owl-base.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/owlbarn/owl/releases/download/1.1/owl-1.1.tbz;
      sha256 = "126agxlhqh5hvya6n8f7zc1ighkraf15g86fpp259pgpdikh4dlq";
    };
    meta.platforms = lib.platforms.all;
  });
  owl = osuper.owl.overrideAttrs (_: {
    inherit (owl-base) version src meta;
  });


  ounit2 = osuper.ounit2.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/lib/ounit2/advanced/dune --replace " bytes " " "
    '';
  });

  ocaml-protoc = osuper.ocaml-protoc.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace \
        src/compilerlib/pb_codegen_util.ml \
        src/compilerlib/pb_codegen_backend.ml \
        src/compilerlib/pb_codegen_encode_binary.ml \
        --replace "String.capitalize " "String.capitalize_ascii "

      substituteInPlace \
        src/compilerlib/pb_codegen_util.ml \
        src/compilerlib/pb_codegen_backend.ml \
        src/compilerlib/pb_codegen_encode_binary.ml \
        --replace "String.lowercase" "String.lowercase_ascii "

      substituteInPlace \
        src/compilerlib/pb_codegen_util.ml \
        --replace "Char.uppercase " "Char.uppercase_ascii "
    '';
  });
  parmap = osuper.parmap.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "rdicosmo";
      repo = "parmap";
      rev = "1.2.5";
      sha256 = "sha256-tBu7TGtDOe5FbxLZuz6nl+65aN9FHIngq/O4dJWzr3Q=";
    };
  });

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

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mmottl";
      repo = "postgresql-ocaml";
      rev = "42c42e9cb";
      sha256 = "sha256-6xo0P3kBjnzddOHGP6PZ1ODIkQoZ7pNlTHLrDcd1EYM=";
    };

    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config ];
    propagatedBuildInputs = [ libpq ];
  });

  pp = disableTests osuper.pp;

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ ocaml-migrate-parsetree-2 ];
  });

  ppx_cstubs = osuper.ppx_cstubs.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml-ppx";
      repo = "ppx_deriving";
      rev = "b4896214b0";
      sha256 = "sha256-+HEpLltTLerHvZftOunRQgXkstUKNgJB2nKDBgD7hr8=";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [
      findlib
      ppxlib
      ppx_derivers
      result
    ];
  });

  ppx_blob = disableTests osuper.ppx_blob;

  ppx_import = osuper.ppx_import.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml-ppx";
      repo = "ppx_import";
      rev = "c9df42cfaa35b9c3a5190d0c6afd8ea90a0017b1";
      sha256 = "sha256-mbjWCpmhWU3nM2vPbXF2n7bLLsxp+Ft8P/w6f3vsWyI=";
    };
  });

  ppxlib = osuper.ppxlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.29.0/ppxlib-0.29.0.tbz;
      sha256 = "1fjqjq9w157wkzgappswm8g1adhb8r4qvs9kfmw3kvzhvd6i12wf";
    };

    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  printbox-text = disableTests osuper.printbox-text;

  progress = osuper.progress.override { mtime = mtime_1; };

  ptime = osuper.ptime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://erratique.ch/software/ptime/releases/ptime-1.1.0.tbz;
      sha256 = "1c9y07vnvllfprf0z1vqf6fr73qxw7hj6h1k5ig109zvaiab3xfb";
    };
  });

  reanalyze =
    if lib.versionOlder "4.13" osuper.ocaml.version then null
    else
      osuper.buildDunePackage {
        pname = "reanalyze";
        version = "2.17.0";
        src = fetchFromGitHub {
          owner = "rescript-association";
          repo = "reanalyze";
          rev = "v2.17.0";
          sha256 = "sha256-BAWWSLn111ihVl1gey+UmMFj1PGDmwkNd5g3kfqcP/Y=";
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

  rock = osuper.rock.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ulrikstrid";
      repo = "opium";
      rev = "830f02fb5462619314153cbe7cedf25e49468648";
      sha256 = "sha256-nvSoLvgrlh/wc5IBN5ZHY/onjXFUFcIs+grQslhwe2w=";
    };
  });
  opium = osuper.opium.overrideAttrs (_: {
    patches = [ ./opium-status.patch ];
  });

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

  sendfile = callPackage ./sendfile { };

  session = callPackage ./session { };
  session-redis-lwt = callPackage ./session/redis.nix { };

  sodium = buildDunePackage {
    pname = "sodium";
    version = "0.8+ahrefs";
    src = fetchFromGitHub {
      owner = "ahrefs";
      repo = "ocaml-sodium";
      rev = "4c92a94a330f969bf4db7fb0ea07602d80c03b14";
      sha256 = "sha256-FRM8F4ID2GOs93Fmt8RLMiz4zbkVTsgqa9Gse6tYvVQ=";
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
    src = fetchFromGitHub {
      owner = "flow";
      repo = "ocaml-sourcemaps";
      rev = "2bc7e6e";
      sha256 = "sha256-eyiK3bhUMswW9cwlKrSTErwseOp/Qn2rKcw4T5DtuOo=";
    };
    propagatedBuildInputs = [ vlq ];
  };

  spelll = osuper.spelll.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/Spelll.ml --replace "Pervasives" "Stdlib"
    '';
  });

  ssl = osuper.ssl.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "savonet";
      repo = "ocaml-ssl";
      rev = "caf30cc";
      sha256 = "sha256-qc4M+EgzmIQxzcMvLQIiYkPXBOvyLb6pNNGj/0OAbcM=";
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

  topkg = osuper.topkg.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://erratique.ch/software/topkg/releases/topkg-1.0.6.tbz;
      sha256 = "11ycfk0prqvifm9jca2308gw8a6cjb1hqlgfslbji2cqpan09kpq";
    };
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
      url = https://github.com/mirleft/ocaml-tls/releases/download/v0.17.0/tls-0.17.0.tbz;
      sha256 = "0yplkpnvwzi7jcg9db3gmj7mmizmf8zp8rcsv4bw8n3anzqfhigs";
    };
    propagatedBuildInputs = [
      cstruct
      domain-name
      fmt
      logs
      hkdf
      mirage-crypto
      mirage-crypto-ec
      mirage-crypto-pk
      mirage-crypto-rng
      ocaml_lwt
      ptime
      x509
      ipaddr
    ];
  });

  tyxml = osuper.tyxml.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocsigen";
      repo = "tyxml";
      rev = "c28e871df6db66a261ba541aa15caad314c78ddc";
      sha256 = "sha256-2dgkuDjeZDJcxZHoZK7uAiPCwg29eYZkTjgsD8OeTQA=";
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
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "utop";
      rev = "bbd9a6ed45";
      sha256 = "sha256-HBKEIyY5boYkwlqOkbZPtyPHbVWcdgMcSpr+xsggAuU=";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ findlib ];
  });

  uuidm = osuper.uuidm.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace pkg/META --replace "bytes" ""
    '';
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

  xenstore-tool = osuper.xenstore-tool.overrideAttrs (o: {
    propagatedBuildInputs = [ camlp-streams ];
    postPatch = ''
      substituteInPlace "cli/dune" --replace \
        "libraries lwt" "libraries camlp-streams lwt"
    '';
  });

  yuscii = disableTests osuper.yuscii;

  zarith = (osuper.zarith.override { gmp = gmp-oc; }).overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "Zarith";
      rev = "64ba1c7";
      sha256 = "sha256-dPe+S68TMGrjSEr+RiawjqAJw2gvwa5BVqFglDgOm1s=";
    };
  });

  zed = osuper.zed.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/zed/releases/download/3.2.0/zed-3.2.0.tbz;
      sha256 = "0gji5rp44mqsld117n8g93cqg8302py1piqshmvg63268fylj8rl";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ uuseg uutf ];
  });

  zmq = osuper.zmq.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "issuu";
      repo = "ocaml-zmq";
      rev = "8a24cd042";
      sha256 = "sha256-EZKDSzW08lNgJgtgNOBgQ8ub29pSy2rwcqoMNu+P3kI=";
    };
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
    src = fetchFromGitHub {
      owner = "aantron";
      repo = "lambdasoup";
      rev = "1.0.0";
      hash = "sha256-PZkhN5vkkLu8A3gYrh5O+nq9wFtig0Q4qD8zLGUGTRI=";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });

  # Jane Street Libraries

  async_js = osuper.async_js.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async_js";
      rev = "v0.15.1";
      sha256 = "sha256-rSBB5eoIQPvMsfU4R3jCx4kCTtNu6NRnTBRIBK0jm0s=";
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

  bonsai = osuper.bonsai.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "bonsai";
      rev = "v0.15.1";
      sha256 = "sha256-WI33l9lt4k3RT3G2UF4OUDRNh85hJGdSkjN9Z2Ph41U=";
    };
    patches = [ ];

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ patdiff ];
  });

  ppx_expect = osuper.ppx_expect.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ stdio ];
  });

  core_unix = osuper.core_unix.overrideAttrs (o: {
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
    pname = "memtrace";
    version = "0.1.2-dev";
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "memtrace";
      rev = "v0.2.3";
      sha256 = "sha256-dWkTrN8ZgNUz7BW7Aut8mfx8o4n8f6UZaDv/7rbbwNs=";
    };
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

  postgres_async = janePackage {
    pname = "postgres_async";
    hash = "sha256-zBLiCoWUZwTdOUUTb0ji+wTxu/PGoi8xC75nYCI10OA=";
    version = "0.15.0";
    meta.description = "OCaml/async implementation of the postgres protocol (i.e., does not use C-bindings to libpq)";
    propagatedBuildInputs = [ ppx_jane core core_kernel async ];
  };

  jst-config = osuper.jst-config.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "jst-config";
      rev = "v0.15.1";
      sha256 = "sha256-wxN3nYjbATsM9peUwJLoYbB+lX9a0X3crF1tyoa55fo=";
    };
    patches = [ ];
  });

  ppx_bench = osuper.ppx_bench.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/ppx_bench.ml --replace \
        "File_path.get_default_path loc" \
        "loc.loc_start.pos_fname"
    '';
  });
  ppx_css = osuper.ppx_css.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_css";
      rev = "v0.15.1";
      sha256 = "sha256-gQTL211CGR1kyzZvOPydhq2/o6Noqm45bv0Y9LTdgAo=";
    };
  });
  ppx_disable_unused_warnings = addBase osuper.ppx_disable_unused_warnings;
  ppx_cold = addBase osuper.ppx_cold;
  ppx_enumerate = addBase osuper.ppx_enumerate;
  ppx_fixed_literal = addBase osuper.ppx_fixed_literal;
  ppx_here = addBase osuper.ppx_here;

  ppx_inline_test = osuper.ppx_inline_test.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/ppx_inline_test.ml --replace \
        "File_path.get_default_path loc" \
        "loc.loc_start.pos_fname"
    '';
  });

  ppx_js_style = addBase osuper.ppx_js_style;
  ppx_module_timer = addStdio osuper.ppx_module_timer;
  ppx_optcomp = addStdio osuper.ppx_optcomp;
  ppx_optional = addBase osuper.ppx_optional;
  ppx_stable = addBase osuper.ppx_stable;

  virtual_dom = osuper.virtual_dom.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "virtual_dom";
      rev = "v0.15.1";
      sha256 = "sha256-Uv6ZDxz2/H0nHjiycUKNQwy/zZyHHmwDEHknFHwDuDs=";
    };
  });

  incr_dom = osuper.incr_dom.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "incr_dom";
      rev = "v0.15.1";
      sha256 = "sha256-4+EwiQCBlI28gt5wTkfEp4vS3AXcwLMutvFAOhSw/p4=";
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
