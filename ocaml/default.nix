{ nixpkgs
, autoconf
, autoreconfHook
, bzip2
, automake
, bash
, buildPackages
, cmake
, fetchpatch
, fetchFromGitHub
, fetchFromGitLab
, fzf
, libgsl
, kerberos
, lib
, libargon2
, libcxx
, libvirt
, libpq
, libev-oc
, libffi-oc
, linuxHeaders
, llvmPackages
, lz4-oc
, net-snmp
, pcre-oc
, sqlite-oc
, makeWrapper
, darwin
, stdenv
, super-opaline
, gmp-oc
, openssl-oc
, oniguruma-lib
, pam
, pkg-config
, python3
, python3Packages
, lmdb
, curl
, libsodium
, cairo
, gtk2
, rdkafka-oc
, zlib-oc
, unzip
, freetype
, fontconfig
, libxkbcommon
, libxcb
, xorg
, zstd-oc
}:

oself: osuper:

let
  nativeCairo = cairo;
  lmdb-pkg = lmdb;
  disableTests = d: d.overrideAttrs (_: { doCheck = false; });
  addBase = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.base ];
  });
  addStdio = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.stdio ];
  });

  # Jane Street
  janePackage =
    oself.callPackage "${nixpkgs}/pkgs/development/ocaml-modules/janestreet/janePackage_0_15.nix" {
      defaultVersion = "0.16.0";
    };

  janeStreet =
    let
      jsBase = import ./janestreet-0.16.nix {
        self = oself;
        openssl = openssl-oc;
        postgresql = libpq;
        inherit
          bash
          fetchpatch
          fetchFromGitHub
          fzf
          lib
          kerberos
          linuxHeaders
          pam
          net-snmp;
        zstd = zstd-oc;
      };
    in
    jsBase // {
      ppx_accessor = jsBase.ppx_accessor.overrideAttrs (_: {
        postPatch = ''
          substituteInPlace src/ppx_accessor.ml \
            --replace "open! Base" "module Typey = Type;; open! Base" \
            --replace "Type." "Typey."
        '';
      });

      streamable = jsBase.streamable.overrideAttrs (_: {
        postPatch = ''
          substituteInPlace ppx/src/clause.mli ppx/src/clause.ml \
                            ppx/src/tuple_clause.ml \
                            ppx/src/helpers.ml ppx/src/helpers.mli \
                            ppx/src/keyed_container_clause.ml \
                            ppx/src/sexp_clause.ml \
                            ppx/src/core_primitive_clause.ml \
                            ppx/src/or_error_clause.ml \
                            ppx/src/type_parameter_clause.ml \
                            ppx/src/parameterized_type_clause.ml \
                            ppx/src/atomic_clause.ml \
                            ppx/src/module_dot_t_clause.ml \
                            ppx/src/ppx_streamable.ml \
            --replace "open! Base" "module Typey = Type;; open! Base" \
            --replace "Type." "Typey."
        '';
      });
    };

in

with oself;

{
  inherit janePackage janeStreet;

  angstrom = osuper.angstrom.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "angstrom";
      rev = "1ca889cc641a1c57e33f6e63d0e3be41087a4931";
      hash = "sha256-JuiAKMRTXiTEh5jko51qaVWIQ6noq9lpYH9Qnzljfuc=";
    };
    propagatedBuildInputs = [ bigstringaf ];
  });

  argon2 = buildDunePackage {
    pname = "argon2";
    version = "1.0.2";
    src = builtins.fetchurl {
      url = https://github.com/Khady/ocaml-argon2/releases/download/1.0.2/argon2-1.0.2.tbz;
      sha256 = "01gjs2b0nzyjfjz1aay8f209jlpr1880qizk96kn8kqgi5bhwfrl";
    };
    propagatedBuildInputs = [ ctypes dune-configurator ctypes-foreign result libargon2 ];
  };

  atdgen-codec-runtime = osuper.atdgen-codec-runtime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ahrefs/atd/releases/download/2.12.0/atdts-2.12.0.tbz;
      sha256 = "1h2g1aravv24brn9j6h9pydg7hlm5zvg86lm45hcpcfxjay0qlq2";
    };
  });
  atdts = buildDunePackage {
    pname = "atdts";
    inherit (atdgen-codec-runtime) version src;
    propagatedBuildInputs = [ atd cmdliner ];
  };

  apron = osuper.apron.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "antoinemine";
      repo = "apron";
      rev = "v0.9.14-beta1";
      hash = "sha256-j7Fp1IEaq7rSF+3OufYQPn5ZWLzOcIEJQWiqG0E+Wtk=";
    };

    configurePhase = ''
      runHook preConfigure
      ./configure -prefix $out \
        ${if stdenv.isDarwin then "--absolute-dylibs" else ""} \
        --debug \
        --no-strip
      mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs
      runHook postConfigure
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

  backoff = buildDunePackage {
    pname = "backoff";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/backoff/releases/download/0.1.0/backoff-0.1.0.tbz;
      sha256 = "0013ikss0nq6yi8yjpkx67qnnpb3g6l8m386vqsd344y49war90i";
    };
  };

  bap = callPackage "${nixpkgs}/pkgs/development/ocaml-modules/bap" {
    inherit (llvmPackages) llvm;
  };
  ppx_bap = callPackage "${nixpkgs}/pkgs/development/ocaml-modules/ppx_bap" { };

  base32 = buildDunePackage {
    pname = "base32";
    version = "dev";
    src = builtins.fetchurl {
      url = https://gitlab.com/public.dream/dromedar/ocaml-base32/-/archive/main/ocaml-base32-main.tar.gz;
      sha256 = "0babid89q3vpgvq10cw233k9xzblsk89vh02ymviblgfjhm92lk5";
    };
  };

  batteries = buildDunePackage {
    pname = "batteries";
    version = "dev";
    src =
      fetchFromGitHub {
        owner = "ocaml-batteries-team";
        repo = "batteries-included";
        rev = "v3.7.0";
        hash = "sha256-5kl5Vypi2ov3iMm+l4Kwe42mUWWz1Xn6/HANQ1HC1ys=";
      };

    propagatedBuildInputs = [ num camlp-streams ];
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

  bigarray-overlap = osuper.bigarray-overlap.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./freestanding/Makefile --replace "pkg-config" "\$(PKG_CONFIG)"
    '';
  });

  bigstringaf = osuper.bigstringaf.overrideAttrs (o: {
    buildInputs = [ dune-configurator ];
    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "bigstringaf";
      rev = "0.9.1";
      hash = "sha256-SFp5QBb4GDcTzEzvgkGKCiuUUm1k8jlgjP6ndzcQBP8=";
    };
  });

  binaryen = callPackage ./binaryen { };

  bisect_ppx = osuper.bisect_ppx.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ ppxlib cmdliner ];
  });

  bos = osuper.bos.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "bos";
      rev = "v0.2.1";
      sha256 = "sha256-ga7CwQpXntW0wg6tP9/c16wfSGEf07DfZdd7b6cp0r0=";
    };
  });

  bz2 = stdenv.mkDerivation rec {
    pname = "ocaml${ocaml.version}-bz2";
    version = "0.7.0";

    src = fetchFromGitLab {
      owner = "irill";
      repo = "camlbz2";
      rev = version;
      sha256 = "sha256-jBFEkLN2fbC3LxTu7C0iuhvNg64duuckBHWZoBxrV/U=";
    };

    autoreconfFlags = [ "-I" "." ];

    nativeBuildInputs = [
      autoreconfHook
      ocaml
      findlib
    ];

    propagatedBuildInputs = [
      bzip2
    ];

    strictDeps = true;

    preInstall = "mkdir -p $OCAMLFIND_DESTDIR/stublibs";
    postPatch = ''
      substituteInPlace bz2.ml --replace "Pervasives" "Stdlib"
      substituteInPlace bz2.mli --replace "Pervasives" "Stdlib"
    '';

    meta = with lib; {
      description = "OCaml bindings for the libbz2 (AKA, bzip2) (de)compression library";
      downloadPage = "https://gitlab.com/irill/camlbz2";
      license = licenses.lgpl21;
      maintainers = with maintainers; [ ];
    };
  };

  ca-certs-nss = osuper.ca-certs-nss.overrideAttrs (_: {
    version = "3.92";
    src = builtins.fetchurl {
      url = https://github.com/mirage/ca-certs-nss/releases/download/v3.92/ca-certs-nss-3.92.tbz;
      sha256 = "0f05qwslhx8sy15sv8rr7lzdg63b5zgnjp89150a5xhf6kk8b9qp";
    };
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

  camlzip = (osuper.camlzip.override { zlib = zlib-oc; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "xavierleroy";
      repo = "camlzip";
      rev = "3b0e0a5f7";
      sha256 = "sha256-DflyuI2gt8HQI8qAgczClVdLy21uXT1A9VMD5cTaDl4=";
    };
  });

  charInfo_width = osuper.charInfo_width.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "kandu";
      repo = "charInfo_width";
      rev = "2.0.0";
      hash = "sha256-JYAa3awHqW5lS4a+TSyK3+xQSi123PhfWwNUt5iOmjg=";
    };
  });

  camomile = osuper.camomile.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "camomile";
      rev = "v2.0.0";
      hash = "sha256-HklX+VPD0Ta3Knv++dBT2rhsDSlDRH90k4Cj1YtWIa8=";
    };
    propagatedBuildInputs = [ camlp-streams dune-site ];
    checkInputs = [ stdlib-random ];
    dontConfigure = true;
    doCheck = true;
    postInstall = null;
  });

  checkseum = osuper.checkseum.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/checkseum/releases/download/v0.5.0/checkseum-0.5.0.tbz;
      sha256 = "0bnyzxvagc4cvpz0a434xngk9ra1mjjh67nhyv3qz5ghk5s6a5bv";
    };
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

  cmarkit = osuper.cmarkit.overrideAttrs (_: {
    buildPhase = "${topkg.buildPhase} --with-cmdliner true";
  });

  carton = disableTests osuper.carton;
  carton-lwt = disableTests osuper.carton-lwt;

  caqti = osuper.caqti.overrideAttrs (o: {
    version = "2.0.1";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-caqti";
      rev = "46f0d96799d892ace1c6b6aafb1d6a4124142f83";
      hash = "sha256-7u821uXHv1Hv2xtmxOR0s/CVeB72Jfdh6WInvHg5I70=";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ipaddr mtime lwt-dllist ];
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

  http = buildDunePackage {
    pname = "http";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-cohttp/releases/download/v6.0.0_alpha2/cohttp-6.0.0.alpha2.tbz;
      sha256 = "1xngq0kanna3j1v6lmbdwh31w4lgbasfa1r0q4kk9hf1694d201g";
    };
    doCheck = false;
  };

  cohttp = osuper.cohttp.overrideAttrs (o: {
    inherit (http) src version;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ http ];
    doCheck = false;
  });
  cohttp-lwt-jsoo = disableTests osuper.cohttp-lwt-jsoo;
  cohttp-top = disableTests osuper.cohttp-top;


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
    patches = [ ];
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

  containers = osuper.containers.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "c-cube";
      repo = "ocaml-containers";
      rev = "v3.12";
      hash = "sha256-15Wd6k/NvjAvTmxlPlZPClODBtFXM6FG3VxniC66u88=";
    };
  });
  containers-data = osuper.containers-data.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace tests/data/t_bitfield.ml --replace ".Make ()" ".Make (struct end)"
    '';
  });

  # Not available for 4.12 and breaking the static build
  cooltt = null;

  cry = osuper.cry.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace "bytes" ""
    '';
  });

  cryptokit = osuper.cryptokit.override { zlib = zlib-oc; };

  ctypes = buildDunePackage rec {
    pname = "ctypes";
    version = "0.21.1";
    src = fetchFromGitHub {
      owner = "ocamllabs";
      repo = "ocaml-ctypes";
      rev = "0.21.1";
      hash = "sha256-Cay+8dwFxw4d1OgMP4CR94l4ic2269YCAaziesEqwHM=";
    };

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ integers bigarray-compat libffi-oc.dev ];
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

  domainslib = osuper.domainslib.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/domainslib/releases/download/0.5.1/domainslib-0.5.1.tbz;
      sha256 = "00axhfwyyjzqvsb3ff3giy0nswdyw2jzrmn56sbl96frlpxmvhi8";
    };
    propagatedBuildInputs = [ domain-local-await saturn ];
    checkInputs = [
      qcheck
      qcheck-multicoretests-util
      qcheck-stm
      mirage-clock-unix
      kcas
    ];
  });

  dream-pure = callPackage ./dream/pure.nix { };
  dream-httpaf = callPackage ./dream/httpaf.nix { };
  dream =
    let mf = multipart_form.override { upstream = true; }; in
    callPackage ./dream {
      multipart_form = mf;
      multipart_form-lwt = multipart_form-lwt.override { multipart_form = mf; };
    };

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
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "dune";
      rev = "ade58ac71a5829a6df376a103078422d451e4e5c";
      hash = "sha256-6kA9fJhg8dKaESLLouArR1XVg/5bugvBV5Wj7QlGx9I=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ makeWrapper ];
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
    src = builtins.fetchurl {
      url = https://github.com/ocaml-dune/fiber/releases/download/3.7.0/fiber-lwt-3.7.0.tbz;
      sha256 = "10ln7cf7l3nc43ji8iwwh9i3p4d355s8hdnfk4lr9rizx5da2j46";
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

  facile = buildDunePackage rec {
    pname = "facile";
    version = "1.1.4";

    src = builtins.fetchurl {
      url = "https://github.com/Emmanuel-PLF/facile/releases/download/${version}/facile-${version}.tbz";
      sha256 = "0jqrwmn6fr2vj2rrbllwxq4cmxykv7zh0y4vnngx29f5084a04jp";
    };

    doCheck = true;
    postPatch = "echo '(lang dune 2.0)' > dune-project";
    meta = {
      homepage = "http://opti.recherche.enac.fr/facile/";
      license = lib.licenses.lgpl21Plus;
      description = "A Functional Constraint Library";
    };
  };

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
      url = https://anmonteiro.s3.eu-west-3.amazonaws.com/fix-20230505.tar.gz;
      sha256 = "06q8h71q9j1jcr1gprr1ykigb9l4y6zil6c7i9p0b0f4qkyhcvrj";
    };
  });

  ff-pbt = osuper.ff-pbt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ alcotest ];
  });

  flow_parser = callPackage ./flow_parser { };

  functoria = osuper.functoria.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage/releases/download/v4.4.0/mirage-4.4.0.tbz;
      sha256 = "09rykqfb4v6jd7p3lvv9d70x40qgh13s93h365i7v85rvr0ysbm7";
    };
  });

  functory = osuper.functory.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace network.ml --replace "Pervasives." "Stdlib."
    '';
  });

  gen_js_api = disableTests osuper.gen_js_api;

  getopt = osuper.getopt.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "scemama";
      repo = "ocaml-getopt";
      rev = "20230213";
      hash = "sha256-oYDm945LgjIW+8x7UrO4FlbHywnu8480aiEVvnjBxc8=";
    };
  });

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

  gsl = buildDunePackage {
    pname = "gsl";
    version = "1.24.3";
    minimalOCamlVersion = "4.12";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dune-configurator libgsl ];
    propagatedBuildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Accelerate ];
    src = fetchFromGitHub {
      owner = "mmottl";
      repo = "gsl-ocaml";
      rev = "38fc895";
      hash = "sha256-Nm/H9O83Q7JZAua3vhv94MBHkxbawAVg7qFW60fbDGE=";
    };
    postPatch = ''
      substituteInPlace ./src/dune --replace "bigarray" ""
    '';
  };

  gstreamer = osuper.gstreamer.overrideAttrs (o: {
    buildInputs = o.buildInputs ++
    lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];
  });

  hacl-star = osuper.hacl-star.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./dune --replace "libraries " "libraries ctypes.stubs "
    '';
  });

  hack_parallel = osuper.hack_parallel.override { sqlite = sqlite-oc; };

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  hpack = callPackage ./h2/hpack.nix { };

  hdr_histogram = buildDunePackage {
    pname = "hdr_histogram";
    version = "0.0.3";

    dontUseCmakeConfigure = true;
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/hdr_histogram_ocaml/releases/download/v0.0.3/hdr_histogram-0.0.3.tbz;
      sha256 = "05d4w4a5x9kgyx02px2biggkbs8id4xlij2w7gfj663ppc1jr49d";
    };

    nativeBuildInputs = [ cmake ];
    propagatedBuildInputs = [ zlib-oc ctypes ];
  };

  hilite = buildDunePackage {
    pname = "hilite";
    version = "0.3.0";
    src = builtins.fetchurl {
      url = https://github.com/patricoferris/hilite/releases/download/v0.3.0/hilite-0.3.0.tbz;
      sha256 = "130rpa4d4335vchzry2bnyxnr34d0s0skv0ba5cx3q4srh4155wv";
    };

    propagatedBuildInputs = [ omd textmate-language ];
  };

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

  iomux = osuper.iomux.overrideAttrs (_: {
    hardeningDisable = [ "strictoverflow" ];
  });

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  irmin = osuper.irmin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/irmin/releases/download/3.8.0/irmin-3.8.0.tbz;
      sha256 = "0wi9yyli4mrl1yd340rpcp558g6cwf9rm39zp3x8dvlwf7k1fh6s";
    };
  });
  irmin-pack-tools = buildDunePackage {
    pname = "irmin-pack-tools";
    inherit (irmin) src version;
    propagatedBuildInputs = [
      ppx_repr
      cmdliner
      ppx_irmin
      ptime
      irmin-pack
      hex
      notty
      irmin-tezos
    ];
  };
  irmin-git = disableTests osuper.irmin-git;
  irmin-http = disableTests osuper.irmin-http;

  iostream = buildDunePackage {
    pname = "iostream";
    version = "0.1";
    src = builtins.fetchurl {
      url = https://github.com/c-cube/ocaml-iostream/releases/download/v0.1/iostream-0.1.tbz;
      sha256 = "0gipllhlzd9xzhy4xkvxg8qnpdcd013knyhfc64cx83vzv0f0v98";
    };
  };

  index = osuper.index.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/index/releases/download/1.6.2/index-1.6.2.tbz;
      sha256 = "0q48mgn29dxrh14isccq5bqrs12whn3fsw6hrvp49vd4k188724k";
    };
  });

  iso639 = buildDunePackage {
    pname = "iso639";
    version = "0.0.5";
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-iso639/releases/download/v0.0.5/iso639-v0.0.5.tbz;
      sha256 = "11bk38m5wsh3g4pr1px3865w8p42n0cq401pnrgpgyl25zdfamk0";
    };
  };

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

  kafka = (osuper.kafka.override {
    rdkafka = rdkafka-oc;
    zlib = zlib-oc;
  }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-kafka";
      rev = "4ee21d040050272105bbdae7336732cc80ad8f00";
      hash = "sha256-oU9pUSLXn6SGAj5iBvC8FJpooG0kt52kvHwCoO9ZvJE=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ];
    buildInputs = [ dune-configurator ];
    hardeningDisable = [ "strictoverflow" ];
  });

  kafka_async = buildDunePackage {
    pname = "kafka_async";
    inherit (kafka) src version;
    propagatedBuildInputs = [ async kafka ];
    hardeningDisable = [ "strictoverflow" ];
    postPatch = ''
      substituteInPlace lib_async/kafka_async.ml \
        --replace "Time.Span" "Time_float.Span" \
        --replace "Int.Table.add_exn" "Hashtbl.add_exn" \
        --replace "Int.Table.find_and_remove" "Hashtbl.find_and_remove" \
        --replace "String.Table.add_exn" "Hashtbl.add_exn" \
        --replace "String.Table.find" "Hashtbl.find" \
        --replace "String.Table.mem" "Hashtbl.mem" \
        --replace "String.Table.keys" "Hashtbl.keys" \
        --replace "String.Table.remove" "Hashtbl.remove"
    '';
  };

  kafka_lwt = osuper.kafka_lwt.overrideAttrs (_: {
    hardeningDisable = [ "strictoverflow" ];
  });

  # Added by the ocaml5.nix
  kcas = null;

  lacaml = osuper.lacaml.overrideAttrs (_: {
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace src/dune --replace " bigarray" ""
      '' else "";
  });

  lambdapi = osuper.lambdapi.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/Deducteam/lambdapi/releases/download/2.4.0/lambdapi-2.4.0.tbz;
      sha256 = "1dlc88jpq5ys8n8saz5af3xacjdprpyvc3r1vzkv0fkc1adap73k";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ dream ];
    propagatedBuildInputs = [
      bindlib
      cmdliner
      dream
      lwt_ppx
      menhirLib
      pratter
      sedlex
      timed
      why3
    ];
  });

  lambda-term = osuper.lambda-term.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "lambda-term";
      rev = "3.3.2";
      hash = "sha256-T2DDpHqLar1sgmju0PLvhAZef5VzOpPWcFVhuZlPQmM=";
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

  lilv = osuper.lilv.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "ctypes.foreign" "ctypes-foreign"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ctypes-foreign ];
  });

  linol = osuper.linol.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "c-cube";
      repo = "linol";
      rev = "bb92d7d73b721f8faf55b3518df5b4bc93250a4d";
      hash = "sha256-WdtJ+Ixo3byXxfU14E4MRQbGZBzPjbyEI9XMC95QxXY=";
    };
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
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ lmdb-pkg dune-configurator ];
    propagatedBuildInputs = [ bigstringaf ];
  };

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

  luv = osuper.luv.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/aantron/luv/releases/download/0.5.12/luv-0.5.12.tar.gz;
      sha256 = "1h2n9iij4mh60sy3g437p1xwqyqpyw72fgh4417d8j9ahq46m7vn";
    };
    propagatedBuildInputs = [ ctypes ];
  });

  luv_unix = buildDunePackage {
    pname = "luv_unix";
    inherit (luv) version src;
    propagatedBuildInputs = [ luv ];
  };

  lwt = (osuper.lwt.override { libev = libev-oc; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocsigen";
      repo = "lwt";
      rev = "5.7.0";
      hash = "sha256-o0wPK6dPdnsr/LzwcSwbIGcL85wkDjdFuEcAxuS/UEs=";
    };
  });

  lwt-watcher = osuper.lwt-watcher.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/70f826c503cc094ed2de3aa81fa385ea9fddb903.tar.gz;
      sha256 = "0q1qdmagldhwrcqiinsfag6zxcn5wbvn2p10wpyi8rgk27q3l8sk";
    };
  });

  lwt_react = callPackage ./lwt/react.nix { };

  lz4 = buildDunePackage {
    pname = "lz4";
    version = "1.3.0";
    src = builtins.fetchurl {
      url = https://github.com/whitequark/ocaml-lz4/releases/download/v1.3.0/lz4-1.3.0.tbz;
      sha256 = "13i4fjvhybnys1x7fjf5k07abq9khh68zr4pqy72si0n740d5frw";
    };
    propagatedBuildInputs = [ dune-configurator ctypes lz4-oc ];
  };

  magic-mime = osuper.magic-mime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-magic-mime/releases/download/v1.3.0/magic-mime-1.3.0.tbz;
      sha256 = "176dywi6d1s1jn1g1c8f9bznj1r6ajgqp5g196fgszld52598dfq";
    };
  });

  markup-lwt = buildDunePackage {
    pname = "markup-lwt";
    inherit (markup) src version;
    propagatedBuildInputs = [ markup lwt ];
  };

  matrix-common = callPackage ./matrix { };
  matrix-ctos = callPackage ./matrix/ctos.nix { };
  matrix-stos = callPackage ./matrix/stos.nix { };

  mdx = osuper.mdx.overrideAttrs (o: {
    doCheck = false;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ cmdliner result ];
    postPatch = ''
      substituteInPlace lib/dune --replace "astring" "astring result"
    '';
  });

  mirage-crypto = osuper.mirage-crypto.overrideAttrs (_: {
    # https://github.com/mirage/mirage-crypto/pull/182
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "mirage-crypto";
      rev = "f35ec71ca11f544a6918e60dfa4564de0f4897ce";
      hash = "sha256-FHftjHj5jR8bLr5X6JLXuWqnyLCvGC/upiSyhDbH9y4=";
    };
  });
  mirage-crypto-pk = osuper.mirage-crypto-pk.override { gmp = gmp-oc; };

  # `mirage-fs` needs to be updated to match `mirage-kv`'s new interface
  mirage-kv = osuper.mirage-kv.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage-kv/releases/download/v6.1.0/mirage-kv-6.1.0.tbz;
      sha256 = "0i6faba2nrm2ayq8f6dvgvcv53b811k77ibi7jp4138jpj2nh4si";
    };
    propagatedBuildInputs = [ fmt optint lwt ptime ];
  });

  mirage-kv-mem = buildDunePackage {
    pname = "mirage-kv-mem";
    version = "3.2.1";
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage-kv-mem/releases/download/v3.2.1/mirage-kv-mem-3.2.1.tbz;
      sha256 = "07qr508kb4v9acybncz395p0mnlakib3r8wx5gk7sxdxhmic1z59";
    };
    propagatedBuildInputs = [ optint mirage-kv fmt ptime mirage-clock ];
  };

  mirage-logs = osuper.mirage-logs.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage-logs/releases/download/v2.0.0/mirage-logs-2.0.0.tbz;
      sha256 = "086x45sijjldg1vcvf7lq23fqxrl8mbbp2ym8hja7gl6m9j759pj";
    };
  });

  mirage-vnetif = osuper.mirage-vnetif.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/vnetif/dune --replace "result" ""
    '';
  });

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
    propagatedBuildInputs = [ ];
  });

  logs-ppx = callPackage ./logs-ppx { };

  landmarks = callPackage ./landmarks { };
  landmarks-ppx = callPackage ./landmarks/ppx.nix { };

  melange =
    if lib.versionAtLeast ocaml.version "5.1" then
      callPackage ./melange { }
    else null;

  menhirLib = osuper.menhirLib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://anmonteiro.s3.eu-west-3.amazonaws.com/menhir-20230608.tar.gz;
      sha256 = "1kmj8b954cdpb7gfyfi7hmvsc1h4b2sfl6nhr9z7kkgbpm9wmlh9";
    };
  });

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
    src = builtins.fetchurl {
      url = https://github.com/mirage/metrics/releases/download/v0.4.1/metrics-0.4.1.tbz;
      sha256 = "0k8lqvrwfal5jwy45l0aq1hkrvjv0k30pv5hvc1n3l61nl7w5q3p";
    };
  });
  metrics-unix = osuper.metrics-unix.overrideAttrs (_: {
    postPatch = null;
  });

  mew = osuper.mew.overrideAttrs (_: {
    propagatedBuildInputs = [ trie ];
    postPatch = ''
      substituteInPlace src/dune --replace "result" ""
    '';
  });

  mlgmpidl = osuper.mlgmpidl.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "nberth";
      repo = "mlgmpidl";
      rev = "1.2.15";
      hash = "sha256-+s8g/WpiTpvKeFJzmq79c8G/5Yipx3wac1T6DqDRS+U=";
    };
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

  # Upstream keeps mtime_1 but we've moved past that need
  mtime_1 = mtime;

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

  nonstd = buildDunePackage rec {
    pname = "nonstd";
    version = "0.0.3";

    minimalOCamlVersion = "4.02";

    src = builtins.fetchurl {
      url = "https://bitbucket.org/smondet/${pname}/get/${pname}.${version}.tar.gz";
      sha256 = "1gn9pawdqlnnc8qsna17ypik7f686gr86zipiw4srmzb7c293b26";
    };

    postPatch = "echo '(lang dune 2.0)' > dune-project";
    doCheck = true;

    meta = with lib; {
      homepage = "https://bitbucket.org/smondet/nonstd";
      description = "Non-standard mini-library";
      license = licenses.isc;
      maintainers = [ maintainers.alexfmpe ];
    };
  };

  num = (osuper.num.override { withStatic = true; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "num";
      rev = "f06af1fda2e722542cc5f2d2d4d1f4441055a92f";
      hash = "sha256-WdH2W5K7UykxCnJu+AwBeRsHR+TWpDyJX3sqF7mk+Cw=";
    };
    buildFlags = [ "opam-modern" ];
    patches = [ ];
    installPhase = ''
      # Not sure if this is entirely correct, but opaline doesn't like `lib_root`
      substituteInPlace num.install --replace lib_root lib
      OCAMLRUNPARAM=b ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR num.install
    '';
  });

  ocaml = (osuper.ocaml.override { flambdaSupport = true; }).overrideAttrs (_: {
    enableParallelBuilding = true;
  });

  ocamlformat-rpc-lib = buildDunePackage {
    pname = "ocamlformat-rpc-lib";
    inherit (ocamlformat-lib) src version;

    minimumOCamlVersion = "4.08";
    strictDeps = true;

    propagatedBuildInputs = [ csexp ];
  };

  ocamlfuse = osuper.ocamlfuse.overrideAttrs (_: {
    meta = {
      platforms = lib.platforms.all;
    };
  });

  ocamlgraph = osuper.ocamlgraph.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/backtracking/ocamlgraph/releases/download/2.1.0/ocamlgraph-2.1.0.tbz;
      sha256 = "0r9d61yva190bdwyz79az6r2d95nfjq43bsm74wz4g95z4v2r5hg";
    };
  });

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace "src/config/discover.ml" --replace \
        'let cmd = pkg_export ^ " pkg-config ' \
        'let cmd = let pkg_config = match Sys.getenv "PKG_CONFIG" with | s -> s | exception Not_found -> "pkg-config" in pkg_export ^ " " ^ pkg_config ^ " '
    '';
  });

  odep = buildDunePackage {
    pname = "odep";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://github.com/sim642/odep/releases/download/0.2.0/odep-0.2.0.tbz;
      sha256 = "15sjb5s1j6mns6dkddm3lbwd0n499smffrs55sw0xfczn3vaxaiv";
    };
    propagatedBuildInputs = [
      bos
      opam-state
      parsexp
      ppx_deriving
      sexplib
      ppx_sexp_conv
      cmdliner
    ];
  };

  odoc-parser = osuper.odoc-parser.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml-doc";
      repo = "odoc-parser";
      rev = "f98cfe3";
      hash = "sha256-xWGDR0gcakLDubzSLM29mAy0HhkSAsOpzxEgBj6hNII=";
    };
    propagatedBuildInputs = [ astring camlp-streams ];
    postPatch = ''
      substituteInPlace src/dune --replace "result" ""
    '';
  });

  ocaml_libvirt = osuper.ocaml_libvirt.override {
    libvirt = disableTests libvirt;
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

  ocaml-recovery-parser = (osuper.ocaml-recovery-parser.override { }).overrideAttrs (o: {
    postPatch = ''
      substituteInPlace "menhir-recover/emitter.ml" --replace \
        "String.capitalize" "String.capitalize_ascii"
    '';
  });

  ocaml_gettext = osuper.ocaml_gettext.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "gildor478";
      repo = "ocaml-gettext";
      rev = "9fa474310f383abf3d4349a25c44955ee62410c1";
      hash = "sha256-QYKWtHJMHVU86aWh9f6zlB4nuzgQYvignA01m3b54Kg=";
    };
  });

  ocp-indent = osuper.ocp-indent.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace "libraries bytes" "libraries "
    '';
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ocp-index = osuper.ocp-index.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocamlpro";
      repo = "ocp-index";
      rev = "1.3.5";
      hash = "sha256-Zn3BPaMB68V363OljFFdmLyYf+S0wFJK44L8t1TSG1Q=";
    };
  });

  ocplib-simplex = buildDunePackage {
    pname = "ocplib-simplex";
    version = "dev";
    src = fetchFromGitHub {
      owner = "ocamlpro";
      repo = "ocplib-simplex";
      rev = "eac35128d5ab4f48af4b972cd77cd9257a250db5";
      hash = "sha256-OAU7JXGlLJYhsaOdZJbHHn63AYBSyTmG/jYXxZ5hjXI=";
    };

    propagatedBuildInputs = [ logs ];
  };

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

  ocurl = osuper.ocurl.overrideAttrs (_: {
    propagatedBuildInputs = [ curl ];
  });

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

  omd = osuper.omd.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/omd/releases/download/2.0.0.alpha4/omd-2.0.0.alpha4.tbz;
      sha256 = "076zc9mbz9698lcx5fw0hvllbv4n29flglz64n15n02vhybrd5lk";
    };
    preBuild = "";
    propagatedBuildInputs = [ uutf uucp uunf dune-build-info ];
  });

  oniguruma = buildDunePackage {
    pname = "oniguruma";
    version = "0.1.2";
    src = builtins.fetchurl {
      url = https://github.com/alan-j-hu/ocaml-oniguruma/releases/download/0.1.2/oniguruma-0.1.2.tbz;
      sha256 = "0rc70nwgx4bqm3h7rar2pmnh543np67rw5m8f6gwzhrwvbykzxp3";
    };
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ oniguruma-lib ];
  };

  swhid_core = buildDunePackage {
    pname = "swhid_core";
    version = "0.1";
    src = fetchFromGitHub {
      owner = "ocamlpro";
      repo = "swhid_core";
      rev = "0.1";
      hash = "sha256-uLnVbptCvmBeNbOjGjyAWAKgzkKLDTYVFY6SNH2zf0A=";
    };
  };
  spdx_licenses = buildDunePackage {
    pname = "spdx_licenses";
    version = "1.2.0";
    src = fetchFromGitHub {
      owner = "kit-ty-kate";
      repo = "spdx_licenses";
      rev = "v1.2.0";
      hash = "sha256-GRadJmX+ddzYa8XwX1Nxe7iYIkcumI94fuTCq6FHAGA=";
    };
  };
  x0install-solver = buildDunePackage {
    pname = "0install-solver";
    version = "2.18";
    src = builtins.fetchurl {
      url = https://github.com/0install/0install/releases/download/v2.18/0install-2.18.tbz;
      sha256 = "1hr0k47cxqcsycxhmn2ajaakfwnap1m24p068k5xy9hsihqlp334";
    };
  };
  opam-0install-cudf = buildDunePackage {
    pname = "opam-0install-cudf";
    version = "0.4.3";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-opam/opam-0install-solver/releases/download/v0.4.3/opam-0install-cudf-0.4.3.tbz;
      sha256 = "12jv2kk6fkapa04w4f0c6iy5lfw9hcy23ghfyn7pk3x5vnyhx7nm";
    };
    propagatedBuildInputs = [ cudf x0install-solver ];
  };

  opam-client = buildDunePackage {
    pname = "opam-client";
    inherit (opam-format) src version meta;
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ cmdliner base64 re opam-repository opam-solver opam-state ];
  };
  opam = buildDunePackage {
    pname = "opam";
    inherit (opam-format) src version meta;
    nativeBuildInputs = [ curl ];
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ cmdliner opam-client ];
  };
  opam-core = osuper.opam-core.overrideAttrs (o: {
    inherit (opam-format) src version meta;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ uutf swhid_core jsonm sha ];
    postPatch = ''
      substituteInPlace src/core/dune --replace "bigarray" ""
    '';
  });
  opam-repository = osuper.opam-repository.overrideAttrs (o: {
    configureFlags = [ "--disable-checks" ];
  });
  opam-solver = buildDunePackage {
    pname = "opam-solver";
    inherit (opam-format) src version meta;
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ opam-0install-cudf re dose3 opam-format ];
  };
  opam-format = osuper.opam-format.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "opam";
      rev = "2.2.0-alpha";
      hash = "sha256-zFfAbxzQStJ5OhrlWZtpY11LzRq4RmnMlH56bDOkDtM=";
    };
    version = "2.2.0-alpha";
    meta = with lib; {
      description = "A package manager for OCaml";
      homepage = "https://opam.ocaml.org/";
      changelog = "https://github.com/ocaml/opam/raw/${version}/CHANGES";
      maintainers = [ maintainers.henrytill maintainers.marsam ];
      license = licenses.lgpl21Only;
      platforms = platforms.all;
    };
  });
  opam-state = osuper.opam-state.overrideAttrs (o: {
    inherit (opam-format) src version meta;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ spdx_licenses ];
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
    meta.platforms = lib.platforms.all;
  });
  owl = osuper.owl.overrideAttrs (_: {
    meta = owl-base.meta;
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

  ocaml_pcre = osuper.ocaml_pcre.override { pcre = pcre-oc; };

  # These require crowbar which is still not compatible with newer cmdliner.
  pecu = disableTests osuper.pecu;

  pgocaml = osuper.pgocaml.overrideAttrs (o: {
    patches = [ ];
    postPatch = ''
      substituteInPlace src/dune --replace \
        "(libraries calendar" \
        "(libraries camlp-streams calendar"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ camlp-streams ];
  });
  pg_query = callPackage ./pg_query { };

  binning = buildDunePackage {
    pname = "binning";
    version = "0.0.0";
    src = builtins.fetchurl {
      url = https://github.com/pveber/binning/releases/download/v0.0.0/binning-v0.0.0.tbz;
      sha256 = "1xvz337wkfrs005hrjm09vzmccxfgk954kliwr8bjwqvvdrb2vvq";
    };
  };
  biotk = buildDunePackage {
    pname = "biotk";
    version = "0.2.0";
    src = builtins.fetchurl {
      url = https://github.com/pveber/biotk/releases/download/v0.2.0/biotk-0.2.0.tbz;
      sha256 = "1c5zbjd3dvzk7sn91zh4bq3wp7w01b4kj9m06y9bd6jc7rbdn2qm";
    };
    propagatedBuildInputs = [
      angstrom-unix
      camlzip
      vg
      ppx_compare
      ppx_csv_conv
      ppx_deriving
      ppx_expect
      ppx_fields_conv
      ppx_inline_test
      ppx_let
      ppx_sexp_conv
      uri
      tyxml
      rresult
      gsl
      fmt
      core_unix
      binning
    ];
    nativeBuildInputs = [ crunch.bin ];
  };

  phylogenetics = osuper.phylogenetics.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/biocaml/phylogenetics/releases/download/v0.2.0/phylogenetics-0.2.0.tbz;
      sha256 = "0sppv1rvr3xky8na99qxrq1lyhn6v40c70is0vmv6nvjgakmhni4";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ yojson biotk ];
  });

  plist-xml = buildDunePackage {
    pname = "plist-xml";
    version = "";
    src = builtins.fetchurl {
      url = https://github.com/alan-j-hu/ocaml-plist-xml/releases/download/0.5.0/plist-xml-0.5.0.tbz;
      sha256 = "1hw3l8q8ip56niszh24yr6dijm7da2rrixdyviffyxv4c9dhd1di";
    };
    nativeBuildInputs = [ menhir ];
    propagatedBuildInputs = [ menhirLib xmlm base64 cstruct iso8601 ];
  };

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mmottl";
      repo = "postgresql-ocaml";
      rev = "42c42e9cb";
      sha256 = "sha256-6xo0P3kBjnzddOHGP6PZ1ODIkQoZ7pNlTHLrDcd1EYM=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ];

    postPatch = ''
      substituteInPlace src/dune --replace " bigarray" ""
    '';
  });

  pp = disableTests osuper.pp;
  pprint = osuper.pprint.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "fpottier";
      repo = "pprint";
      rev = "20230830";
      hash = "sha256-avf71vAgCL1MU8O7Q3FNN3wEdCDtbNZP0ipETnn8AqA=";
    };
  });

  ppx_cstruct = disableTests osuper.ppx_cstruct;

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
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  re = osuper.re.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/ocaml-re/releases/download/1.11.0/re-1.11.0.tbz;
      sha256 = "0kwdvzb2wy3rxq3mvmsgc8cdwrzka2viysvrmrrbxxn0h13j9z01";
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

  repr = osuper.repr.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/repr/releases/download/0.7.0/repr-0.7.0.tbz;
      sha256 = "1b014p74l0mi3gk9klwv9mzip3p92rr0v0dnxqh0x2mzhpzcknla";
    };
  });

  resto-cohttp-server = osuper.resto-cohttp-server.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/server.ml --replace \
        "wseq ic oc body" "wseq (ic.Cohttp_lwt_unix.Private.Input_channel.chan) oc body"

      substituteInPlace src/server.mli --replace \
        "'d Lwt_io.channel" "Cohttp_lwt_unix.Private.Input_channel.t"
    '';
  });

  rfc7748 = osuper.rfc7748.overrideAttrs (o: {
    patches = [ ];
    src = fetchFromGitHub {
      owner = "burgerdev";
      repo = "ocaml-rfc7748";
      rev = "ed034213ff02cd55870ae1387e91deebc9838eb4";
      hash = "sha256-26w6YcjBgfe2Fz/Z0RvCdU0MR4MAxIk2HGQ0ri0rrqU=";
    };
    checkInputs = o.checkInputs ++ [ hex ];
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

  rope = buildDunePackage rec {
    pname = "rope";
    version = "0.6.2";
    minimalOCamlVersion = "4.03";

    src = builtins.fetchurl {
      url = "https://github.com/Chris00/ocaml-rope/releases/download/${version}/rope-${version}.tbz";
      sha256 = "15cvfa0s1vjx7gjd07d3fkznilishqf4z4h2q5f20wm9ysjh2h2i";
    };

    buildInputs = [ benchmark ];
    postPatch = ''
      substituteInPlace "src/dune" --replace "bytes" ""
      substituteInPlace "src/rope.ml" --replace "Pervasives" "Stdlib"
    '';

    meta = {
      homepage = "https://github.com/Chris00/ocaml-rope";
      description = "Ropes (“heavyweight strings”) in OCaml";
      license = lib.licenses.lgpl21;
      maintainers = with lib.maintainers; [ ];
    };
  };

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anuragsoni/routes/releases/download/2.0.0/routes-2.0.0.tbz;
      sha256 = "126nn0gbh12i7yf0qn01ryfp2qw0aj1xfk1vq42fa01biilrsqiv";
    };
  });

  semver = buildDunePackage {
    pname = "semver";
    version = "0.2.0";
    src = builtins.fetchurl {
      url = https://github.com/rgrinberg/ocaml-semver/releases/download/0.2.1/semver-0.2.1.tbz;
      sha256 = "1f4qyrzh8y72k96dyh8l8m2sb2sl5bhny9ijxgnppr0yv99c6g0a";
    };
  };

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

  soundtouch = osuper.soundtouch.overrideAttrs (o: {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
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

  srt = osuper.srt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ctypes-foreign ];
    postPatch = ''
      substituteInPlace "src/dune" "src/stubs/dune" --replace \
        "ctypes.foreign" "ctypes-foreign"
    '';
  });

  ssl = (osuper.ssl.override { openssl = openssl-oc.dev; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "savonet";
      repo = "ocaml-ssl";
      rev = "v0.7.0";
      hash = "sha256-gi80iwlKaI4TdAVnCyPG03qRWFa19DHdTrA0KMFBAc4=";
    };
    nativeCheckInputs = [ openssl-oc.bin ];
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  stdlib-random = buildDunePackage {
    pname = "stdlib-random";
    version = "1.1.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml/stdlib-random/releases/download/1.1.0/stdlib-random-1.1.0.tbz;
      sha256 = "0n95h57z0d9hf1y5a3v7bbci303wl63jn20ymnb8n2v8zs1034wb";
    };
    nativeBuildInputs = [ cppo ];
    doCheck = true;
  };

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

  syslog = osuper.syslog.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "syslog.ml" --replace "%.15s" "%s"
    '';
  });

  taglib = osuper.taglib.overrideAttrs (o: {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  });

  tar = osuper.tar.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-tar/releases/download/v2.5.1/tar-2.5.1.tbz;
      sha256 = "1x1xik316m3a6d616bwa9c9s2ji50g8p3hs9ckhmp837hr40yi6k";
    };
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
  tar-unix = disableTests osuper.tar-unix;

  textmate-language = buildDunePackage {
    pname = "textmate-language";
    version = "0.3.4";
    src = builtins.fetchurl {
      url = https://github.com/alan-j-hu/ocaml-textmate-language/releases/download/0.3.4/textmate-language-0.3.4.tbz;
      sha256 = "17c540ddzqzl8c72rzpm3id6ixi91cq5r8dmjvf0kzj6kjdgrg63";
    };
    propagatedBuildInputs = [ oniguruma ];
  };

  terminal = osuper.terminal.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/craigfe/progress/releases/download/0.2.2/progress-0.2.2.tbz;
      sha256 = "1d8h87xkslsh4khfa3wlcz1p55gmh4wyrafgnnsxc7524ccw4h9k";
    };
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
    src = fetchFromGitHub {
      owner = "mirleft";
      repo = "ocaml-tls";
      rev = "19e5eff864483956551499622a45deda0e795576";
      hash = "sha256-B7DCunKP1NfC+cjiNGQrp/RU61mGFnXm6MyPyizujBc=";
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

  torch = osuper.torch.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/wrapper/dune --replace "ctypes.foreign" "ctypes-foreign"
    '';
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
    propagatedBuildInputs =
      o.propagatedBuildInputs ++
      [ ctypes-foreign ] ++
      lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Accelerate ];
    doCheck = !stdenv.isDarwin;
    checkPhase = "dune runtest --profile=release";
  });

  tsdl = osuper.tsdl.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace _tags --replace "ctypes.foreign" "ctypes-foreign"
    '';
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

  tsdl-image = osuper.tsdl-image.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "sanette";
      repo = "tsdl-image";
      rev = "0.6";
      hash = "sha256-mgTFwkuFJVwJmHrzHSdNh8v4ehZIcWemK+eLqjglw5o=";
    };
  });

  tsdl-mixer = osuper.tsdl-mixer.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "sanette";
      repo = "tsdl-mixer";
      rev = "0.6";
      hash = "sha256-szuGmLzgGyQExCQwpopVNswtZZdhP29Q1+uNQJZb43Q=";
    };
  });

  tsdl-ttf = osuper.tsdl-ttf.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "sanette";
      repo = "tsdl-ttf";
      rev = "0.6";
      hash = "sha256-1MGbsekaBoCz4vAwg+Dfzsl0xUKgs8dUEr+OpLopnig=";
    };
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

  uri = osuper.uri.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "ocaml-uri";
      rev = "cca065b1e6f9c6271eb60d16179806a775b08579";
      hash = "sha256-y/RfO87ffRZhdFxhfCJRE7Mcs/lq7yOZ6Sv8twcD4Sw=";
    };
    doCheck = false;
  });

  unix-errno = osuper.unix-errno.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "xapi-project";
      repo = "ocaml-unix-errno";
      rev = "a36eec0aa612141ababbc8131a489bc6df7094a8";
      hash = "sha256-8e5NR69LyHnNdbDA/18OOYCUtsJW0h3mZkgxiQ85/QI=";
    };
    propagatedBuildInputs = [ ctypes integers ];
  });

  unstrctrd = disableTests osuper.unstrctrd;

  uring = osuper.uring.overrideAttrs (_: {
    postPatch = ''
      patchShebangs vendor/liburing/configure
      substituteInPlace lib/uring/dune --replace \
        '(run ./configure)' '(bash "./configure")'
    '';
  });

  uutf = osuper.uutf.overrideAttrs (_: {
    pname = "uutf";
  });

  vg = osuper.vg.overrideAttrs (_: {
    propagatedBuildInputs = [
      uchar
      gg
      uutf
      otfm
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  });
  visitors = osuper.visitors.overrideAttrs (_: {
    propagatedBuildInputs = [ ppxlib ppx_deriving ];
  });

  vlq = buildDunePackage {
    pname = "vlq";
    version = "0.2.1";

    src = builtins.fetchurl {
      url = https://github.com/flowtype/ocaml-vlq/releases/download/v0.2.1/vlq-v0.2.1.tbz;
      sha256 = "02wr9ph4q0nxmqgbc67ydf165hmrdv9b655krm2glc3ahb6larxi";
    };

    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ camlp-streams ];
    postPatch = ''
      substituteInPlace "src/dune" --replace \
        '(public_name vlq))' '(libraries camlp-streams)(public_name vlq))'
    '';
  };

  websocketaf = callPackage ./websocketaf { };
  websocketaf-lwt = callPackage ./websocketaf/lwt.nix { };
  websocketaf-lwt-unix = callPackage ./websocketaf/lwt-unix.nix { };
  websocketaf-async = callPackage ./websocketaf/async.nix { };
  websocketaf-mirage = callPackage ./websocketaf/mirage.nix { };

  why3 = callPackage ./why3 { inherit nixpkgs; };

  yuscii = disableTests osuper.yuscii;

  zarith = (osuper.zarith.override { gmp = gmp-oc; }).overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "Zarith";
      rev = "release-1.13";
      hash = "sha256-CNVKoJeO3fsmWaV/dwnUA8lgI4ZlxR/LKCXpCXUrpSg=";
    };
  });

  zed = osuper.zed.overrideAttrs (o: {
    propagatedBuildInputs = [ react uchar uutf uucp uuseg ];
    postPatch = ''
      substituteInPlace src/dune --replace "result" ""
    '';
  });

  zmq = osuper.zmq.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "issuu";
      repo = "ocaml-zmq";
      rev = "8a24cd042";
      sha256 = "sha256-EZKDSzW08lNgJgtgNOBgQ8ub29pSy2rwcqoMNu+P3kI=";
    };
  });
} // janeStreet // (
  if lib.hasPrefix "5." osuper.ocaml.version
  then (import ./ocaml5.nix { inherit oself darwin fetchFromGitHub; })
  else { }
) // (
  if lib.versionAtLeast osuper.ocaml.version "5.1"
  then (import ./melange-packages.nix { inherit oself fetchFromGitHub; })
  else { }
)
