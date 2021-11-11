{ callPackage, gcc, libpq, lib, stdenv, openssl }:

oself: osuper:

with oself;
let
  janestreetPackages = callPackage ./janestreet {
    ocamlPackages = oself;
    inherit osuper;
  };

  morphPackages = callPackage ./morph {
    ocamlPackages = oself;
  };

  oidcPackages = callPackage ./oidc {
    ocamlPackages = oself;
  };

  sessionPackages = callPackage ./session {
    ocamlPackages = oself;
  };

in
janestreetPackages //
morphPackages //
oidcPackages //
sessionPackages // {
  afl-persistent = osuper.afl-persistent.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib ];
  });

  arp = osuper.arp.overrideAttrs (_: {
    doCheck = ! stdenv.isDarwin;
  });

  archi = callPackage ./archi {
    ocamlPackages = oself;

  };

  archi-lwt = callPackage ./archi/lwt.nix {
    ocamlPackages = oself;
  };

  archi-async = callPackage ./archi/async.nix {
    ocamlPackages = oself;
  };

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

  calendar = callPackage ./calendar { ocamlPackages = oself; };

  camlp5 = osuper.camlp5.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/camlp5/camlp5/archive/rel8.00.02.tar.gz;
      sha256 = "1zbp8mr9ms4253nh9z34dd2ppin4bri82j7xy3jdk73k9dbmr31w";
    };
  });

  carl = callPackage ./piaf/carl.nix { ocamlPackages = oself; };

  carton = osuper.carton.overrideAttrs (_: {
    doCheck = false;
  });

  caqti = osuper.caqti.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/paurkedal/ocaml-caqti/releases/download/v1.6.0/caqti-v1.6.0.tbz;
      sha256 = "0kb7phb3hbyz541nhaw3lb4ndar5gclzb30lsq83q0s70pbc1w0v";
    };
  });

  cookie = callPackage ./cookie { ocamlPackages = oself; };
  session-cookie = callPackage ./cookie/session.nix { ocamlPackages = oself; };
  session-cookie-lwt = callPackage ./cookie/session-lwt.nix { ocamlPackages = oself; };

  ctypes-0_17 = osuper.ctypes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
      sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
    };
  });

  dataloader = callPackage ./dataloader {
    ocamlPackages = oself;
  };

  dataloader-lwt = callPackage ./dataloader/lwt.nix {
    ocamlPackages = oself;
  };

  decimal = callPackage ./decimal { ocamlPackages = oself; };

  domainslib =
    if osuper.ocaml.version == "4.12.0+multicore+effects" then
      callPackage ./domainslib { ocamlPackages = oself; }
    else null;

  dream = callPackage ./dream { ocamlPackages = oself; };

  dream-livereload = callPackage ./dream-livereload { ocamlPackages = oself; };

  dream-serve = callPackage ./dream-serve { ocamlPackages = oself; };

  # Make `dune` effectively be Dune v2.  This works because Dune 2 is
  # backwards compatible.

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

  easy-format = callPackage ./easy-format { ocamlPackages = oself; };

  ezgzip = buildDunePackage rec {
    pname = "ezgzip";
    version = "0.2.3";
    src = builtins.fetchurl {
      url = "https://github.com/hcarty/${pname}/archive/v${version}.tar.gz";
      sha256 = "0zjss0hljpy3mxpi1ccdvicb4j0qg5dl6549i23smy1x07pr0nmr";
    };
    propagatedBuildInputs = [ rresult astring ocplib-endian camlzip result ];
  };

  flow_parser = callPackage ./flow_parser { ocamlPackages = oself; };

  gluten = callPackage ./gluten {
    ocamlPackages = oself;
  };
  gluten-lwt = callPackage ./gluten/lwt.nix {
    ocamlPackages = oself;
  };
  gluten-lwt-unix = callPackage ./gluten/lwt-unix.nix {
    ocamlPackages = oself;
  };
  gluten-async = callPackage ./gluten/async.nix {
    ocamlPackages = oself;
  };

  graphql_parser = callPackage ./graphql/parser.nix {
    ocamlPackages = oself;
  };
  graphql = callPackage ./graphql {
    ocamlPackages = oself;
  };
  graphql-lwt = callPackage ./graphql/lwt.nix {
    ocamlPackages = oself;
  };
  graphql-async = callPackage ./graphql/async.nix {
    ocamlPackages = oself;
  };

  graphql_ppx = callPackage ./graphql_ppx {
    ocamlPackages = oself;
  };

  gsl = osuper.gsl.overrideAttrs (o: {
    src =
      if lib.versionOlder "4.13" osuper.ocaml.version then
        builtins.fetchurl
          {
            url = https://github.com/mmottl/gsl-ocaml/archive/76f8d93cc.tar.gz;
            sha256 = "0s1h7xrlmq8djaxywq48s1jm7x5f6j7mfkljjw8kk52dfjsfwxw0";
          } else o.src;
  });

  h2 = callPackage ./h2 { ocamlPackages = oself; };
  h2-lwt = callPackage ./h2/lwt.nix { ocamlPackages = oself; };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { ocamlPackages = oself; };
  h2-mirage = callPackage ./h2/mirage.nix { ocamlPackages = oself; };
  h2-async = callPackage ./h2/async.nix { ocamlPackages = oself; };
  hpack = callPackage ./h2/hpack.nix { ocamlPackages = oself; };

  hidapi = osuper.hidapi.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  httpaf = callPackage ./httpaf { ocamlPackages = oself; };
  httpaf-lwt = callPackage ./httpaf/lwt.nix { ocamlPackages = oself; };
  httpaf-lwt-unix = callPackage ./httpaf/lwt-unix.nix { ocamlPackages = oself; };
  httpaf-mirage = callPackage ./httpaf/mirage.nix { ocamlPackages = oself; };
  httpaf-async = callPackage ./httpaf/async.nix { ocamlPackages = oself; };

  hxd = osuper.hxd.overrideAttrs (_: {
    doCheck = false;
  });

  jose = callPackage ./jose { ocamlPackages = oself; };

  ke = osuper.ke.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ke/archive/0b3d570f56c558766e8d53600e59ce65f3218556.tar.gz;
      sha256 = "01i20hxjbvzh2i82g8lk44hvnij5gjdlnapcm55balknpflyxv9f";
    };
  });

  lambda-runtime = callPackage ./lambda-runtime {
    ocamlPackages = oself;
  };
  vercel = callPackage ./lambda-runtime/vercel.nix {
    ocamlPackages = oself;
  };

  logs = osuper.logs.override { jsooSupport = false; };

  logs-ppx = callPackage ./logs-ppx { ocamlPackages = oself; };

  landmarks = callPackage ./landmarks { ocamlPackages = oself; };
  landmarks-ppx = callPackage ./landmarks/ppx.nix { ocamlPackages = oself; };

  lwt = osuper.lwt.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo dune-configurator ];
  });

  melange =
    if (lib.versionOlder "4.12" osuper.ocaml.version && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange { ocamlPackages = oself; }
    else null;

  melange-compiler-libs =
    if ((lib.versionOlder "4.12" osuper.ocaml.version) && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange/compiler-libs.nix { ocamlPackages = oself; }
    else null;

  merlin = callPackage ./merlin { ocamlPackages = oself; };

  mongo = callPackage ./mongo { ocamlPackages = oself; };
  mongo-lwt = callPackage ./mongo/lwt.nix { ocamlPackages = oself; };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { ocamlPackages = oself; };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { ocamlPackages = oself; };
  bson = callPackage ./mongo/bson.nix { ocamlPackages = oself; };

  mrmime = osuper.mrmime.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ hxd jsonm cmdliner ];
  });

  mtime = osuper.mtime.override { jsooSupport = false; };

  multipart_form = callPackage ./multipart_form { ocamlPackages = oself; };

  multipart-form-data = callPackage ./multipart-form-data { ocamlPackages = oself; };

  num = osuper.num.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/num/archive/v1.4.tar.gz;
      sha256 = "090gl27g84r3s2b12vgkz8fp269jqlrhx4lpg7008yviisv8hl01";
    };

    patches = [ ./num/findlib-install.patch ];
  });

  ocaml = osuper.ocaml.override { flambdaSupport = true; };

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

  pg_query = callPackage ./pg_query { ocamlPackages = oself; };

  phylogenetics = osuper.phylogenetics.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/biocaml/phylogenetics/releases/download/v0.0.0/phylogenetics-0.0.0.tbz;
      sha256 = "0knfh2s0jfnsc0vsq5yw5xla7m7i98xd0qv512dyh3jhkh7m00l9";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ menhirLib ];
  });

  piaf = callPackage ./piaf { ocamlPackages = oself; };

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ ocaml-migrate-parsetree-2 ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { ocamlPackages = oself; };

  ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { ocamlPackages = oself; };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { ocamlPackages = oself; };

  ppx_bitstring = osuper.ppx_bitstring.overrideAttrs (o: {
    buildInputs = [ bitstring ppxlib ];
  });

  ppx_cstubs = osuper.ppx_cstubs.overrideAttrs (o: {
    buildInputs = [
      bigarray-compat
      containers
      cppo
      ctypes
      integers
      num
      ppxlib
      re
    ];
  });

  postgresql = (osuper.postgresql.override { postgresql = libpq; });

  ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/e030f13a3.tar.gz;
      sha256 = "0yfb5c8g8h40m4b722qfl00vgddj6apzcd2lhzv01npn2ipnm280";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  reason = callPackage ./reason { ocamlPackages = oself; };
  rtop = callPackage ./reason/rtop.nix { ocamlPackages = oself; };

  reason-native = osuper.reason-native // { qcheck-rely = null; };

  redemon = callPackage ./redemon { ocamlPackages = oself; };

  redis = callPackage ./redis { ocamlPackages = oself; };
  redis-lwt = callPackage ./redis/lwt.nix { ocamlPackages = oself; };
  redis-sync = callPackage ./redis/sync.nix { ocamlPackages = oself; };

  reenv = callPackage ./reenv { ocamlPackages = oself; };

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anuragsoni/routes/releases/download/1.0.0/routes-1.0.0.tbz;
      sha256 = "1s24lbfkbyj5a873viy811vs8hrfxvsz7dqm6vz4bmf06i440aar";
    };
  });

  sedlex = oself.sedlex_2;

  ssl = osuper.ssl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/savonet/ocaml-ssl/archive/e6430aa.tar.gz;
      sha256 = "0x10yjphzi0n0vgjqnlrwz1pc5kzza5mk08c6js29h8drf3nhkr1";
    };

    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl.dev ];
  });

  subscriptions-transport-ws = callPackage ./subscriptions-transport-ws {
    ocamlPackages = oself;
  };

  syndic = buildDunePackage rec {
    pname = "syndic";
    version = "1.6.1";
    src = builtins.fetchurl {
      url = "https://github.com/Cumulus/${pname}/releases/download/v${version}/syndic-v${version}.tbz";
      sha256 = "1i43yqg0i304vpiy3sf6kvjpapkdm6spkf83mj9ql1d4f7jg6c58";
    };
    propagatedBuildInputs = [ xmlm uri ptime ];
  };

  tyxml-jsx = callPackage ./tyxml/jsx.nix { ocamlPackages = oself; };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { ocamlPackages = oself; };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { ocamlPackages = oself; };

  websocketaf = callPackage ./websocketaf {
    ocamlPackages = oself;
  };
  websocketaf-lwt = callPackage ./websocketaf/lwt.nix {
    ocamlPackages = oself;
  };
  websocketaf-lwt-unix = callPackage ./websocketaf/lwt-unix.nix {
    ocamlPackages = oself;
  };
  websocketaf-async = callPackage ./websocketaf/async.nix {
    ocamlPackages = oself;
  };
  websocketaf-mirage = callPackage ./websocketaf/mirage.nix {
    ocamlPackages = oself;
  };

  yuscii = osuper.yuscii.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ gcc ];
  });
}
