{ callPackage, libpq, dot-merlin-reader, opaline, lib, stdenv, pkgconfig, openssl }:

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

  kafka-packages = callPackage ./kafka {
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
kafka-packages //
lambda-runtime-packages //
menhirPackages //
morphPackages //
multicorePackages //
oidcPackages //
reasonPackages //
redisPackages //
sessionPackages //
websocketafPackages // {
  alcotest-mirage = callPackage ./alcotest/mirage.nix { ocamlPackages = oself; };

  arp = osuper.arp.overrideAttrs (_: {
    doCheck = ! stdenv.isDarwin;
  });

  base64 = osuper.base64.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-base64/releases/download/v3.5.0/base64-v3.5.0.tbz;
      sha256 = "19735bvb3k263hzcvdhn4d5lfv2qscc9ib4q85wgxsvq0p0fk7aq";
    };
  });

  bigstring = osuper.bigstring.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/c-cube/ocaml-bigstring/archive/0.3.tar.gz;
      sha256 = "0nipiqarr6d7j2xz9gp5z0pl2x3bs0yg7w7phg10kd7p5sazjrsc";
    };
    doCheck = false;
  });

  calendar = callPackage ./calendar { ocamlPackages = oself; };

  carl = callPackage ./piaf/carl.nix { ocamlPackages = oself; };

  coin = callPackage ./coin { ocamlPackages = oself; };

  containers-data = osuper.containers-data.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  cudf = callPackage ./cudf { ocamlPackages = oself; };

  decimal = callPackage ./decimal { ocamlPackages = oself; };

  dose3 = callPackage ./dose3 { ocamlPackages = oself; };

  # Make `dune` effectively be Dune v2.  This works because Dune 2 is
  # backwards compatible.
  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune;

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

  ocaml_extlib = osuper.ocaml_extlib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://ygrek.org/p/release/ocaml-extlib/extlib-1.7.8.tar.gz";
      sha256 = "0npq4hq3zym8nmlyji7l5cqk6drx2rkcx73d60rxqh5g8dla8p4k";
    };
  });

  faraday-async = callPackage ./faraday/async.nix { ocamlPackages = oself; };
  faraday-lwt = callPackage ./faraday/lwt.nix { ocamlPackages = oself; };
  faraday-lwt-unix = callPackage ./faraday/lwt-unix.nix { ocamlPackages = oself; };

  graphql_ppx = callPackage ./graphql_ppx {
    ocamlPackages = oself;
  };

  httpaf = callPackage ./httpaf { ocamlPackages = oself; };
  httpaf-lwt = callPackage ./httpaf/lwt.nix { ocamlPackages = oself; };
  httpaf-lwt-unix = callPackage ./httpaf/lwt-unix.nix { ocamlPackages = oself; };
  httpaf-mirage = callPackage ./httpaf/mirage.nix { ocamlPackages = oself; };
  httpaf-async = callPackage ./httpaf/async.nix { ocamlPackages = oself; };

  hidapi = osuper.hidapi.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  irmin = osuper.irmin.overrideAttrs (o: {
    doCheck = false;
    checkInputs = [ ];
  });
  irmin-http = osuper.irmin-http.overrideAttrs (o: {
    doCheck = false;
  });
  irmin-unix = osuper.irmin-unix.overrideAttrs (o: {
    doCheck = false;
  });

  iter = osuper.iter.overrideAttrs (o: { doCheck = false; });

  janeStreet = janestreetPackages;

  jose = callPackage ./jose { ocamlPackages = oself; };

  ke = osuper.ke.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/ke/archive/0b3d570f56c558766e8d53600e59ce65f3218556.tar.gz;
      sha256 = "01i20hxjbvzh2i82g8lk44hvnij5gjdlnapcm55balknpflyxv9f";
    };
  });

  logs-ppx = callPackage ./logs-ppx { ocamlPackages = oself; };

  luv = callPackage ./luv { ocamlPackages = oself; };

  lwt = osuper.lwt.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocsigen/lwt/archive/5.4.0.tar.gz;
      sha256 = "00wbx1gr38b8pivv1blrzkrwq9qqqq0hbsvkdndcrzyh83q5ypwc";
    };
    buildInputs = [ ocaml dune findlib cppo dune-configurator ];
  });

  magic-mime = callPackage ./magic-mime {
    ocamlPackages = oself;
  };

  merlin = osuper.merlin.overrideAttrs (o: {
    src =

      if (lib.versionOlder "4.12" osuper.ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.0/merlin-v4.0-412.tbz;
            sha256 = "0n60rf7w48kik9cl5m4kzklp8cxiamqad1qb01ikb8xma7f094p6";
          }
      else if (lib.versionOlder "4.11" osuper.ocaml.version)
      then dot-merlin-reader.src
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v3.4.2/merlin-v3.4.2.tbz;
          sha256 = "109ai1ggnkrwbzsl1wdalikvs1zx940m6n65jllxj68in6bvidz1";
        };
  });

  mirage-clock = osuper.mirage-clock.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });
  mirage-clock-unix = osuper.mirage-clock-unix.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  mrmime = callPackage ./mrmime { ocamlPackages = oself; };

  mtime = osuper.mtime.override { jsooSupport = false; };

  multipart_form = callPackage ./multipart_form { ocamlPackages = oself; };

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

  ocp-build = osuper.ocp-build.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocp-build/archive/104e4656ca6dba9edb03b62539c9f1e10abcaae8.tar.gz;
      sha256 = "01qn6w6dc1g4pr4s031jblx41vv635r29hkasvlc71c5zs2szvwy";
    };
  });

  ocplib-endian = callPackage ./ocplib-endian { ocamlPackages = oself; };

  ocp-index = osuper.ocp-index.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/OCamlPro/ocp-index/archive/b33d9470c7cfd0d247dbb2c1e8ed7c1a7eed1054.tar.gz;
      sha256 = "0y1jff2hk1igr44cx30pkbbikqg6iniahr6n81h54vvqzsg0q1wg";
    };
  });

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

  ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

  ppxlib = osuper.ppxlib.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.22.0/ppxlib-0.22.0.tbz;
      sha256 = "0ykdp55i6x1a5mbxjlvwcfvs4kvzxqnn2bi2lf224rk677h93sry";
    };
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ocaml-migrate-parsetree-2-1
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving/releases/download/v5.2.1/ppx_deriving-v5.2.1.tbz;
      sha256 = "11h75dsbv3rs03pl67hdd3lbim7wjzh257ij9c75fcknbfr5ysz9";
    };
    propagatedBuildInputs = [ ppxlib result ppx_derivers ];
  });

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ppx_deriving_yojson/archive/bc744e25765c7d6b4f65e3a484021aa736d7c919.tar.gz;
      sha256 = "07vqa59p3pbk8bhizvn2z0p5z615cxyh4lnr1i4skn03s5wqvjin";
    };
    propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
  });

  ptime = (osuper.ptime.override { jsooSupport = false; });

  redemon = callPackage ./redemon { ocamlPackages = oself; };

  reenv = callPackage ./reenv { ocamlPackages = oself; };

  rosetta = callPackage ./rosetta { ocamlPackages = oself; };

  routes = callPackage ./routes { ocamlPackages = oself; };

  ssl = osuper.ssl.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    propagatedBuildInputs = [ openssl.dev ];
  });

  stdlib-shims = osuper.stdlib-shims.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/stdlib-shims/releases/download/0.3.0/stdlib-shims-0.3.0.tbz;
      sha256 = "0jnqsv6pqp5b5g7lcjwgd75zqqvcwcl5a32zi03zg1kvj79p5gxs";
    };
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

  yojson = callPackage ./yojson { ocamlPackages = oself; };
  yuscii = callPackage ./yuscii { ocamlPackages = oself; };

  zarith = osuper.zarith.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/zarith/archive/b229acfbdc85d3de3650283e4ad07b77c0f59c2f.tar.gz;
      sha256 = "06kzlx6adczn0a40pwl66dn0jbmz4laah4v46fyxkhxybyg1cvcv";
    };
  });
}
