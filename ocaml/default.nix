{ callPackage, fetchFromGitHub, libpq, opaline, lib, stdenv, openssl, which }:

oself: osuper:

with oself;
let
  archiPackages = callPackage ./archi {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

  cookiePackages = callPackage ./cookie {
    ocamlPackages = oself;
  };

  dataloader-packages = callPackage ./dataloader {
    ocamlPackages = oself;
  };

  graphqlPackages = callPackage ./graphql {
    ocamlPackages = oself;
  };

  glutenPackages = callPackage ./gluten {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

  janestreetPackages = callPackage ./janestreet {
    ocamlPackages = oself;
  };

  lambda-runtime-packages = callPackage ./lambda-runtime {
    ocamlPackages = oself;
  };

  morphPackages = callPackage ./morph {
    ocamlPackages = oself;
  };

  multicorePackages =
    if osuper.ocaml.version == "4.10.0+multicore+no-effect-syntax" then {
      domainslib = callPackage ./domainslib { ocamlPackages = oself; };
    } else { };

  oidcPackages = callPackage ./oidc {
    ocamlPackages = oself;
  };

  redisPackages = callPackage ./redis {
    ocamlPackages = oself;
  };

  sessionPackages = callPackage ./session {
    ocamlPackages = oself;
  };

  websocketafPackages = callPackage ./websocketaf {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

in
archiPackages //
cookiePackages //
dataloader-packages //
graphqlPackages //
glutenPackages //
janestreetPackages //
lambda-runtime-packages //
morphPackages //
multicorePackages //
oidcPackages //
redisPackages //
sessionPackages //
websocketafPackages // {
  ansiterminal = buildDunePackage {
    pname = "ANSITerminal";
    version = "0.8.2";
    src = builtins.fetchurl {
      url = https://github.com/Chris00/ANSITerminal/releases/download/0.8.2/ANSITerminal-0.8.2.tbz;
      sha256 = "04n15ki9h1qawlhkxbglzfbx0frm593nx2cahyh8riwc2g46q148";
    };
  };

  afl-persistent = osuper.afl-persistent.overrideAttrs (o: {
    nativeBuildInputs = [ ocaml findlib ];
  });

  arp = osuper.arp.overrideAttrs (_: {
    doCheck = ! stdenv.isDarwin;
  });

  batteries = osuper.batteries.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-batteries-team/batteries-included/archive/2e027673.tar.gz;
      sha256 = "09gp2k3434xbchc8mm97ksqmi7ds7x204pqwf9d1kv56yvrcd6ld";
    };
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
    version = "1.5.1";
    src = fetchFromGitHub {
      owner = "paurkedal";
      repo = "ocaml-caqti";
      rev = "v1.5.1";
      sha256 = "1vl61kdyj89whc3mh4k9bis6rbj9x2scf6hnv9afyalp4j65sqx1";
    };
  });

  ctypes-0_17 = osuper.ctypes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
      sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
    };
  });

  decimal = callPackage ./decimal { ocamlPackages = oself; };

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

  graphql_ppx = callPackage ./graphql_ppx {
    ocamlPackages = oself;
  };

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

  logs = osuper.logs.override { jsooSupport = false; };

  logs-ppx = callPackage ./logs-ppx { ocamlPackages = oself; };

  landmarks = callPackage ./landmarks { ocamlPackages = oself; };
  landmarks-ppx = callPackage ./landmarks/ppx.nix { ocamlPackages = oself; };

  lwt = osuper.lwt.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ cppo dune-configurator ];
  });

  melange =
    if (lib.versionOlder "4.12" osuper.ocaml.version && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange
        {
          ocamlPackages = oself;
        } else null;

  melange-compiler-libs =
    if ((lib.versionOlder "4.12" osuper.ocaml.version) && !(lib.versionOlder "4.13" osuper.ocaml.version)) then
      callPackage ./melange/compiler-libs.nix
        {
          ocamlPackages = oself;
        } else null;

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

  piaf = callPackage ./piaf { ocamlPackages = oself; };

  ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ ocaml-migrate-parsetree-2 ];
  });

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { ocamlPackages = oself; };

  ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { ocamlPackages = oself; };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { ocamlPackages = oself; };

  postgresql = (osuper.postgresql.override { postgresql = libpq; });

  ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/bc744e25765c7d6b4f65e3a484021aa736d7c919.tar.gz;
      sha256 = "07vqa59p3pbk8bhizvn2z0p5z615cxyh4lnr1i4skn03s5wqvjin";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  reason = callPackage ./reason { ocamlPackages = oself; };
  rtop = callPackage ./reason/rtop.nix { ocamlPackages = oself; };

  reason-native = osuper.reason-native // { qcheck-rely = null; };

  redemon = callPackage ./redemon { ocamlPackages = oself; };

  reenv = callPackage ./reenv { ocamlPackages = oself; };

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anuragsoni/routes/releases/download/1.0.0/routes-1.0.0.tbz;
      sha256 = "1s24lbfkbyj5a873viy811vs8hrfxvsz7dqm6vz4bmf06i440aar";
    };
  });

  sedlex_3 = osuper.sedlex_2.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/sedlex/archive/v2.3.tar.gz;
      sha256 = "0n0gg8iax9jjnv0azisjaqxr7p3vx2a5pwc9rsq40fsqbvmr1c7r";
    };

    propagatedBuildInputs = [
      gen
      uchar
      ppxlib
    ];
  });

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

  uunf = osuper.uunf.overrideAttrs (o: {
    # https://github.com/ocaml/ocaml/issues/9839
    configurePhase = lib.optionalString (lib.versionOlder "4.11" osuper.ocaml.version)
      ''
        runHook preConfigure
        ulimit -s 9216
        runHook postConfigure
      '';
  });

  yuscii = osuper.yuscii.overrideAttrs (_: {
    doCheck = false;
  });
}
