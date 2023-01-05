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

  bencode = buildDunePackage {
    pname = "bencode";
    version = "2.0";
    src = builtins.fetchurl {
      url = "https://github.com/rgrinberg/bencode/archive/2.0.tar.gz";
      sha256 = "233eae0817126e9c4a781bf1329d834672b77954e6b983a4d0a298d1e2ff0756";
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

  caqti = osuper.caqti.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-caqti/archive/eca8ecb.tar.gz;
      sha256 = "07d65n34539zldy50byg9r3sznchq1gl19f65x8c29m519a9gm80";
    };

    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ipaddr ];
  });

  caqti-async = osuper.caqti-async.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ conduit-async ];
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
      src = builtins.fetchurl {
        url = https://github.com/paurkedal/confero/archive/252cf3e.tar.gz;
        sha256 = "0lj3vrjf4s2gkf2jyd6iz1bsx5vb6cp472496r3lrj07zdz5wgn7";
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

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  irmin = osuper.irmin.override { mtime = mtime_1; };
  irmin-chunk = disableTests osuper.irmin-chunk;
  irmin-fs = disableTests osuper.irmin-fs;
  irmin-pack = disableTests osuper.irmin-pack;
  irmin-git = disableTests osuper.irmin-git;
  irmin-http = disableTests osuper.irmin-http;
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
      substituteInPlace src/dune --replace "(libraries bytes)" ""
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

  jsonm = osuper.jsonm.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/jsonm/archive/7220492e3909002935aa2851edab4ee4eadb324c.tar.gz;
      sha256 = "1fykr7ivn9jmf75f06dpnrvb7v44143wr0n0f6nxj45bxf0mchbd";
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
    src = builtins.fetchurl {
      url = https://github.com/didier-wenzek/ocaml-kafka/archive/2f607bcf.tar.gz;
      sha256 = "168wyh65nmwnhp4w8x5891rw5brcmhiqq9inaq0l73cfc3vax7bb";
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
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/lwt/archive/3d6f0fac.tar.gz;
      sha256 = "1gakp1yy4ngzpssbmmv1ldhmlsp4hlg0wp6zbl7md5s9mvmx5a33";
    };

    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config-script pkg-config cppo ];
    propagatedBuildInputs = [ libev-oc ocplib-endian ];

    postPatch = ''
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
    src = builtins.fetchurl {
      url = https://github.com/thierry-martinez/metapp/releases/download/v0.4.4/metapp.0.4.4.tar.gz;
      sha256 = "0iy2ab5j9v87anj8d3dimy2vzxghryv7cb81yavrwazmjb3j5vmx";
    };
    propagatedBuildInputs = [ ppxlib stdcompat ];
  };

  metrics = osuper.metrics.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/metrics/archive/995eb18d.tar.gz;
      sha256 = "1isjkygn17g8x0563kmfq62xql1wi7cxdy1qiiymnxy6ffn3sc4j";
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
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];

    # https://github.com/mirage/mrmime/issues/91
    doCheck = !lib.versionAtLeast ocaml.version "5.0";
  });

  mtime_1 = osuper.mtime;

  mtime = osuper.mtime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/dbuenzli/mtime/archive/refs/tags/v2.0.0.tar.gz;
      sha256 = "1md8g2sm7ajlb94rgn0p5z73ik3h7mvr2jfhgmbyslsq1syhbn05";
    };
  });

  multipart_form = callPackage ./multipart_form { };
  multipart_form-lwt = callPackage ./multipart_form/lwt.nix { };

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

  ocaml-canvas = buildDunePackage {
    pname = "ocaml-canvas";
    version = "n/a";
    hardeningDisable = [ "strictoverflow" ];
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocaml-canvas/archive/962dedd98.tar.gz;
      sha256 = "0f8rwj664jcv1l31yxiqfb0cnhcz0v6q18n9lf60g231sl9bvcaz";
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
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocplib_stuff/archive/refs/tags/v0.3.0.tar.gz;
      sha256 = "0r5xh2aj1mbmj6ncxzkjzadgz42gw4x0qxxqdcm2m6531pcyfpq5";
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
    src = builtins.fetchurl {
      url = https://github.com/ocamlpro/ocplib-endian/archive/fda4d5525.tar.gz;
      sha256 = "14g214dn6w0gqr9rw2v17ljhcli94fwn81j8z624xqh8kx2050v2";
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
    postPatch = ''
      substituteInPlace src/lib/ounit2/advanced/dune --replace " bytes " " "
    '';
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

  ppx_blob = disableTests osuper.ppx_blob;

  ppx_import = osuper.ppx_import.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_import/archive/c9df42cfaa35b9c3a5190d0c6afd8ea90a0017b1.tar.gz;
      sha256 = "00mhgzzkgggl0qyabhcpspsww9jn9adjj1r3w162vm2cysifaz2v";
    };
  });

  ppxlib = osuper.ppxlib.overrideAttrs (_: {
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  printbox = disableTests osuper.printbox;
  printbox-text = osuper.printbox-text.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/printbox/archive/refs/tags/v0.6.tar.gz;
      sha256 = "1hr6g23b8z0p9kk1g996bzbrrziqk9b2c1za5xyzcq5g3xxqipij";
    };
    preBuild = "rm -rf ./dune";
    doCheck = false;
  });

  progress = osuper.progress.override { mtime = mtime_1; };

  psq = osuper.psq.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/pqwy/psq/releases/download/v0.2.1/psq-0.2.1.tbz;
      sha256 = "0i6k5i3dha3b4syz4jpd5fi6dkalas8bhcpfk4blprxb7r9my022";
    };
  });

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
    src = builtins.fetchurl {
      url = https://github.com/ulrikstrid/opium/archive/830f02fb5462619314153cbe7cedf25e49468648.tar.gz;
      sha256 = "1d8s87ifdq8xnp27dahhy61xflgk4m1pz24qlw81dl2f6r443pcs";
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
      url = https://github.com/ocaml-toml/to.ml/archive/7.1.0.tar.gz;
      sha256 = "1vsjlwsq3q7wf0mcvxszxdl212zwqynr9kjpsxnx894yxlb9qkhx";
    };

    patches = [ ];
  });

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
    pname = "uutf";
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

  bonsai = osuper.bonsai.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/janestreet/bonsai/archive/refs/tags/v0.15.1.tar.gz;
      sha256 = "1gvlxwxsc7j8sc3k4x1c07fdhibbhcgmcyb138gl4gq78r0p2jhc";
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
