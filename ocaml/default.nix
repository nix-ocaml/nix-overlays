{ gcc, lib, libpq, stdenv, openssl, pkg-config, lmdb, curl, writeScriptBin, libsodium }:

oself: osuper:

let
  lmdb-pkg = lmdb;
  script = writeScriptBin "pkg-config" ''
    #!${stdenv.shell}
    ${stdenv.hostPlatform.config}-pkg-config $@
  '';
in

with oself;

{
  arp = osuper.arp.overrideAttrs (_: {
    doCheck = ! stdenv.isDarwin;
  });

  archi = callPackage ./archi { };
  archi-lwt = callPackage ./archi/lwt.nix { };
  archi-async = callPackage ./archi/async.nix { };

  batteries = osuper.batteries.overrideAttrs (o: {
    src =
      if lib.versionOlder "4.13" osuper.ocaml.version then
        builtins.fetchurl
          {
            url = https://github.com/ocaml-batteries-team/batteries-included/archive/2e027673.tar.gz;
            sha256 = "09gp2k3434xbchc8mm97ksqmi7ds7x204pqwf9d1kv56yvrcd6ld";
          }
      else
        o.src;
  });

  calendar = callPackage ./calendar { };

  camlp5 = osuper.camlp5.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/camlp5/camlp5/archive/rel8.00.02.tar.gz;
      sha256 = "1zbp8mr9ms4253nh9z34dd2ppin4bri82j7xy3jdk73k9dbmr31w";
    };
  });
  camlzip = osuper.camlzip.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/xavierleroy/camlzip/archive/refs/tags/rel111.tar.gz;
      sha256 = "0dzdspqp9nzx8wyhclbm68dykvfj6b97c8r7b47dq4qw7vgcbfzz";
    };
    nativeBuildInputs = [ ocaml findlib ];
  });
  astring = osuper.astring.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib topkg ocamlbuild ];
  });
  rresult = osuper.rresult.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib topkg ocamlbuild ];
  });

  carton = osuper.carton.overrideAttrs (_: {
    doCheck = false;
  });

  caqti = osuper.caqti.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-caqti/releases/download/v1.6.0/caqti-v1.6.0.tbz;
      sha256 = "0kb7phb3hbyz541nhaw3lb4ndar5gclzb30lsq83q0s70pbc1w0v";
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

  ctypes-0_17 = osuper.ctypes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
      sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
    };
  });

  dataloader = callPackage ./dataloader { };
  dataloader-lwt = callPackage ./dataloader/lwt.nix { };

  decimal = callPackage ./decimal { };

  domainslib =
    if osuper.ocaml.version == "4.12.0+multicore+effects" then
      callPackage ./domainslib { }
    else null;

  dream = callPackage ./dream {
    multipart_form = multipart_form.override { upstream = true; };
  };

  dream-livereload = callPackage ./dream-livereload { };

  dream-serve = callPackage ./dream-serve { };

  # Make `dune` effectively be Dune v2.  This works because Dune 2 is
  # backwards compatible.

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

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

  flow_parser = callPackage ./flow_parser { };

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
    src =
      if lib.versionOlder "4.13" osuper.ocaml.version then
        builtins.fetchurl
          {
            url = https://github.com/mmottl/gsl-ocaml/archive/76f8d93cc.tar.gz;
            sha256 = "0s1h7xrlmq8djaxywq48s1jm7x5f6j7mfkljjw8kk52dfjsfwxw0";
          } else o.src;
  });

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  hpack = callPackage ./h2/hpack.nix { };

  hidapi = osuper.hidapi.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  httpaf = callPackage ./httpaf { };
  httpaf-lwt = callPackage ./httpaf/lwt.nix { };
  httpaf-lwt-unix = callPackage ./httpaf/lwt-unix.nix { };
  httpaf-mirage = callPackage ./httpaf/mirage.nix { };
  httpaf-async = callPackage ./httpaf/async.nix { };

  hxd = osuper.hxd.overrideAttrs (_: {
    doCheck = false;
  });

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  lmdb = osuper.buildDunePackage {
    pname = "lmdb";
    version = "1.0";
    src = builtins.fetchurl {
      url = https://github.com/Drup/ocaml-lmdb/archive/1.0.tar.gz;
      sha256 = "0nkax7v4yggk21yxgvx3ax8fg74yl1bhj4z09szfblmsxsy5ydd4";
    };
    nativeBuildInputs = [ dune-configurator pkg-config ];
    buildInputs = [ lmdb-pkg ];
    propagatedBuildInputs = [ bigstringaf ];
  };

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
      url = https://github.com/mirage/ke/archive/0b3d570f56c558766e8d53600e59ce65f3218556.tar.gz;
      sha256 = "01i20hxjbvzh2i82g8lk44hvnij5gjdlnapcm55balknpflyxv9f";
    };
  });

  lambda-runtime = callPackage ./lambda-runtime { };
  vercel = callPackage ./lambda-runtime/vercel.nix { };

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

  merlin = callPackage ./merlin { };

  morph = callPackage ./morph { };
  morph_graphql_server = callPackage ./morph/graphql.nix { };

  mongo = callPackage ./mongo { };
  mongo-lwt = callPackage ./mongo/lwt.nix { };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { };
  bson = callPackage ./mongo/bson.nix { };

  mrmime = osuper.mrmime.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];
  });

  mtime = osuper.mtime.override { jsooSupport = false; };

  multipart_form = callPackage ./multipart_form { };

  multipart-form-data = callPackage ./multipart-form-data { };

  num = osuper.num.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/num/archive/v1.4.tar.gz;
      sha256 = "090gl27g84r3s2b12vgkz8fp269jqlrhx4lpg7008yviisv8hl01";
    };

    patches = [ ./num/findlib-install.patch ];
  });

  ocaml = osuper.ocaml.override { flambdaSupport = true; };

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
    if lib.versionOlder "4.13" osuper.ocaml.version then
      null
    else osuper.ocaml-lsp;

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  ocp-build = osuper.ocp-build.overrideDerivation (o: {
    preConfigure = "";
  });

  ocplib-endian = osuper.ocplib-endian.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo ];
  });

  ocurl =
    stdenv.mkDerivation rec {
      name = "ocurl-0.9.1";
      src = builtins.fetchurl {
        url = "http://ygrek.org.ua/p/release/ocurl/${name}.tar.gz";
        sha256 = "0n621cxb9012pj280c7821qqsdhypj8qy9qgrah79dkh6a8h2py6";
      };

      nativeBuildInputs = [ pkg-config ocaml findlib ];
      propagatedBuildInputs = [ curl lwt ];
      createFindlibDestdir = true;
    };
  ppx_tools = osuper.ppx_tools.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo ];
  });


  oidc = callPackage ./oidc { };
  oidc-client = callPackage ./oidc/client.nix { };

  pg_query = callPackage ./pg_query { };

  piaf = callPackage ./piaf { };
  carl = callPackage ./piaf/carl.nix { };

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ ocaml-migrate-parsetree-2 ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  postgresql = (osuper.postgresql.override { postgresql = libpq; });

  postgres_async = osuper.buildDunePackage {
    pname = "postgres_async";
    version = "0.14.0";
    src = builtins.fetchurl {
      url = https://ocaml.janestreet.com/ocaml-core/v0.14/files/postgres_async-v0.14.0.tar.gz;
      sha256 = "0pspfk4bsknxi0hjxav8z1r1y9ngkbq9iw9igy85rxh4a7c92s51";
    };
    propagatedBuildInputs = [ ppx_jane core core_kernel async ];
  };

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/e030f13a3.tar.gz;
      sha256 = "0yfb5c8g8h40m4b722qfl00vgddj6apzcd2lhzv01npn2ipnm280";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  reanalyze =
    if lib.versionOlder "4.13" osuper.ocaml.version then
      null else
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

  redemon = callPackage ./redemon { };

  redis = callPackage ./redis { };
  redis-lwt = callPackage ./redis/lwt.nix { };
  redis-sync = callPackage ./redis/sync.nix { };

  reenv = callPackage ./reenv { };

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
      url = https://github.com/savonet/ocaml-ssl/archive/e6430aa.tar.gz;
      sha256 = "0x10yjphzi0n0vgjqnlrwz1pc5kzza5mk08c6js29h8drf3nhkr1";
    };

    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl.dev ];
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

  tyxml-jsx = callPackage ./tyxml/jsx.nix { };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { };

  websocketaf = callPackage ./websocketaf { };
  websocketaf-lwt = callPackage ./websocketaf/lwt.nix { };
  websocketaf-lwt-unix = callPackage ./websocketaf/lwt-unix.nix { };
  websocketaf-async = callPackage ./websocketaf/async.nix { };
  websocketaf-mirage = callPackage ./websocketaf/mirage.nix { };

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
    propagatedBuildInputs = [ async ctypes-0_17 openssl ];
  };

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
    src = builtins.fetchurl {
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
  }).overrideAttrs
    (_: {
      src = builtins.fetchurl {
        url = https://github.com/janestreet/ppx_variants_conv/archive/6103f6fc56f978c847ba7c1f2d9f38ee93a5e337.tar.gz;
        sha256 = "13006x3jl4fdp845rg2s1h01f44w27ij4i85pqll4r286lsvyyqq";
      };
    });

  protocol_version_header = osuper.protocol_version_header.overrideAttrs (_: {
    propagatedBuildInputs = [ core_kernel ocaml-migrate-parsetree-2 ];
  });
}
