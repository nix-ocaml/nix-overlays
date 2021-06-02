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

  h2Packages = callPackage ./h2 {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

  janestreetPackages = callPackage ./janestreet {
    ocamlPackages = oself;
  };

  junitPackages = callPackage ./junit {
    ocamlPackages = oself;
  };

  lambda-runtime-packages = callPackage ./lambda-runtime {
    ocamlPackages = oself;
  };

  menhirPackages =
    if !lib.versionAtLeast osuper.ocaml.version "4.07"
    then { }
    else
      callPackage ./menhir { ocamlPackages = oself; };

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

  reasonPackages = callPackage ./reason {
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
h2Packages //
janestreetPackages //
junitPackages //
lambda-runtime-packages //
menhirPackages //
morphPackages //
multicorePackages //
oidcPackages //
reasonPackages //
redisPackages //
sessionPackages //
websocketafPackages // {
  alcotest = osuper.alcotest.overrideAttrs (_: {
    doCheck = false;
  });

  alcotest-mirage = callPackage ./alcotest/mirage.nix { ocamlPackages = oself; };

  ansiterminal = buildDunePackage {
    pname = "ANSITerminal";
    version = "0.8.2";
    src = builtins.fetchurl {
      url = https://github.com/Chris00/ANSITerminal/releases/download/0.8.2/ANSITerminal-0.8.2.tbz;
      sha256 = "04n15ki9h1qawlhkxbglzfbx0frm593nx2cahyh8riwc2g46q148";
    };
  };

  arp = osuper.arp.overrideAttrs (_: {
    doCheck = ! stdenv.isDarwin;
  });

  bigstring = osuper.bigstring.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/ocaml-bigstring/archive/0.3.tar.gz;
      sha256 = "0nipiqarr6d7j2xz9gp5z0pl2x3bs0yg7w7phg10kd7p5sazjrsc";
    };
    doCheck = false;
  });

  bitstring = osuper.bitstring.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/xguerin/bitstring/archive/v4.1.0.tar.gz;
      sha256 = "1622ypmqmkk434s9cnyfz1yixpimgi8siphz5nzqllxycr2crw37";
    };
  });

  calendar = callPackage ./calendar { ocamlPackages = oself; };

  camlbz2 = callPackage ./camlbz2 { ocamlPackages = oself; };

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

  coin = callPackage ./coin { ocamlPackages = oself; };

  containers = osuper.containers.overrideAttrs (o: {
    checkInputs = (o.checkInputs or [ ]) ++ [ which ];
  });

  containers-data = osuper.containers-data.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  ctypes-0_17 = osuper.ctypes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
      sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
    };
  });

  cudf = callPackage ./cudf { ocamlPackages = oself; };

  decimal = callPackage ./decimal { ocamlPackages = oself; };

  decompress = osuper.decompress.overrideAttrs (_: {
    doCheck = false;
  });

  dose3 = callPackage ./dose3 { ocamlPackages = oself; };

  dream = callPackage ./dream { ocamlPackages = oself; };

  # Make `dune` effectively be Dune v2.  This works because Dune 2 is
  # backwards compatible.

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

  dune-site = buildDunePackage {
    pname = "dune-site";
    inherit (oself.dune) src version patches;
    useDune2 = true;

    dontAddPrefix = true;

    propagatedBuildInputs = [ dune-private-libs ];
  };

  dune-release = osuper.dune-release.overrideAttrs (o: {
    doCheck = false;
    src = builtins.fetchurl {
      url = https://github.com/ocamllabs/dune-release/archive/5384dff2f79908352f0388bd2621ece3e783b6fe.tar.gz;
      sha256 = "0vyi8sl5q077vb6yhz2lvzp9hnfmhvc6m4nd5sbwa482p3aplnl2";
    };
  });

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

  logs-ppx = callPackage ./logs-ppx { ocamlPackages = oself; };

  landmarks = callPackage ./landmarks { ocamlPackages = oself; };

  lwt = osuper.lwt.overrideAttrs (o: {
    buildInputs = [ ocaml dune findlib cppo dune-configurator ];
  });

  magic-mime = callPackage ./magic-mime {
    ocamlPackages = oself;
  };

  melange =
    if (lib.versionOlder "4.12" osuper.ocaml.version) then
      callPackage ./melange
        {
          ocamlPackages = oself;
        } else null;

  melange-compiler-libs =
    if (lib.versionOlder "4.12" osuper.ocaml.version) then
      callPackage ./melange/compiler-libs.nix
        {
          ocamlPackages = oself;
        } else null;


  merlin = osuper.merlin.overrideAttrs (o: {
    src =
      if (lib.versionOlder "4.12" osuper.ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.1-412/merlin-v4.1-412.tbz;
            sha256 = "13cx0v999ijj48m2zb0rsgi1m42bywm7jc8fsqxkkf5xfggawk7v";
          }
      else if (lib.versionOlder "4.11" osuper.ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.1-411/merlin-v4.1-411.tbz;
            sha256 = "0zckb729mhp1329bcqp0mi1lxxipzbm4a5hqqzrf2g69k73nybly";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v3.4.2/merlin-v3.4.2.tbz;
          sha256 = "109ai1ggnkrwbzsl1wdalikvs1zx940m6n65jllxj68in6bvidz1";
        };
  });

  mongo = callPackage ./mongo { ocamlPackages = oself; };
  mongo-lwt = callPackage ./mongo/lwt.nix { ocamlPackages = oself; };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { ocamlPackages = oself; };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { ocamlPackages = oself; };
  bson = callPackage ./mongo/bson.nix { ocamlPackages = oself; };

  mrmime = callPackage ./mrmime { ocamlPackages = oself; };

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

  ocamlgraph = buildDunePackage {
    pname = "ocamlgraph";
    version = "2.0.0";
    src = builtins.fetchurl {
      url = https://github.com/backtracking/ocamlgraph/releases/download/2.0.0/ocamlgraph-2.0.0.tbz;
      sha256 = "029692bvdz3hxpva9a2jg5w5381fkcw55ysdi8424lyyjxvjdzi0";
    };
    propagatedBuildInputs = [ stdlib-shims ];
  };

  ocplib-endian = callPackage ./ocplib-endian { ocamlPackages = oself; };

  parmap = osuper.parmap.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  pbkdf = callPackage ./pbkdf { ocamlPackages = oself; };

  pg_query = callPackage ./pg_query { ocamlPackages = oself; };

  piaf = callPackage ./piaf { ocamlPackages = oself; };

  ppx_gen_rec = osuper.ppx_gen_rec.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/flowtype/ocaml-ppx_gen_rec/archive/05291d0e65e56da4485ae54599d94c83319f3700.tar.gz;
      sha256 = "05pmx5jj635smp17vpqbc9b50cfz49d8hfgfcjf6b5g7awpdb499";
    };
    buildInputs = (lib.remove oself.ocaml-migrate-parsetree-1-8 o.buildInputs) ++ [ ppxlib ];
  });

  ppx_import = buildDunePackage rec {
    pname = "ppx_import";
    version = "1.8.0";

    useDune2 = true;

    src = builtins.fetchurl {
      url = "https://github.com/ocaml-ppx/ppx_import/releases/download/v${version}/ppx_import-${version}.tbz";
      sha256 = "0zqcj70yyp4ik4jc6jz3qs2xhb94vxc6yq9ij0d5cyak28klc3gv";
    };

    propagatedBuildInputs = [
      ppx_tools_versioned
      ocaml-migrate-parsetree
    ];

  };

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { ocamlPackages = oself; };

  ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { ocamlPackages = oself; };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { ocamlPackages = oself; };

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/bc744e25765c7d6b4f65e3a484021aa736d7c919.tar.gz;
      sha256 = "07vqa59p3pbk8bhizvn2z0p5z615cxyh4lnr1i4skn03s5wqvjin";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  prettym = callPackage ./prettym { ocamlPackages = oself; };

  ptime = (osuper.ptime.override { jsooSupport = false; });

  redemon = callPackage ./redemon { ocamlPackages = oself; };

  reenv = callPackage ./reenv { ocamlPackages = oself; };

  rosetta = callPackage ./rosetta { ocamlPackages = oself; };

  routes = callPackage ./routes { ocamlPackages = oself; };

  sedlex_3 = osuper.sedlex_2.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/sedlex/archive/v2.3.tar.gz;
      sha256 = "0n0gg8iax9jjnv0azisjaqxr7p3vx2a5pwc9rsq40fsqbvmr1c7r";
    };

    propagatedBuildInputs = [
      gen
      uchar
      ocaml-migrate-parsetree-2-1
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

  stringext = callPackage ./stringext { ocamlPackages = oself; };

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

  unstrctrd = callPackage ./unstrctrd { ocamlPackages = oself; };

  uri = callPackage ./uri { ocamlPackages = oself; };

  utop = osuper.utop.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-community/utop/releases/download/2.7.0/utop-2.7.0.tbz;
      sha256 = "1p9z7jk2dqs7qlgjliz6qhn3dw048hhbr6znyb03qz16vx9sqs70";
    };
  });

  uunf = osuper.uunf.overrideAttrs (o: {
    # https://github.com/ocaml/ocaml/issues/9839
    configurePhase = lib.optionalString (lib.versionOlder "4.11" osuper.ocaml.version)
      ''
        ulimit -s 9216
      '';
  });

  uuuu = callPackage ./uuuu { ocamlPackages = oself; };

  visitors = osuper.visitors.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/visitors/-/archive/20210316/archive.tar.gz;
      sha256 = "1scf51n23px1y24xxqsix7p4za283kw6giww2s1524y6h77kf1kb";
    };
  });

  yojson = callPackage ./yojson { ocamlPackages = oself; };
  yuscii = callPackage ./yuscii { ocamlPackages = oself; };

  zmq = osuper.zmq.overrideAttrs
    (o: {
      buildInputs = o.buildInputs ++ [ dune-configurator ];
    });
}
