{ callPackage, libpq, dot-merlin-reader, opaline, lib, stdenv, pkgconfig, openssl }:

oself: osuper:

with oself;

let
  alcotestPackages = callPackage ./alcotest {
    ocamlPackages = oself;
  };

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

  faradayPackages = callPackage ./faraday {
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

  httpafPackages = callPackage ./httpaf {
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

  logsPpxPackages = callPackage ./logs-ppx {
    ocamlPackages = oself;
  };

  menhirPackages = if !lib.versionAtLeast osuper.ocaml.version "4.07"
    then {}
    else callPackage ./menhir {
      ocamlPackages = oself;
    };

  morphPackages = callPackage ./morph {
    ocamlPackages = oself;
  };

  multicorePackages =
    if osuper.ocaml.version == "4.10.0+multicore+no-effect-syntax"  then {
      domainslib = callPackage ./domainslib { ocamlPackages = oself; };
    } else {};

  oidcPackages = callPackage ./oidc {
    ocamlPackages = oself;
  };

  piafPackages = callPackage ./piaf { ocamlPackages = oself; };

  reasonPackages = callPackage ./reason {
    ocamlPackages = oself;
  };

  redisPackages = callPackage ./redis {
    ocamlPackages = oself;
  };

  sessionPackages = callPackage ./session {
    ocamlPackages = oself;
  };

  subscriptionsTransportWsPackages = callPackage ./subscriptions-transport-ws {
    ocamlPackages = oself;
  };

  tyxmlPackages = callPackage ./tyxml {
    ocamlPackages = oself;
  };

  websocketafPackages = callPackage ./websocketaf {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

in
  alcotestPackages //
  archiPackages //
  cookiePackages //
  dataloader-packages //
  faradayPackages //
  graphqlPackages //
  glutenPackages //
  h2Packages //
  httpafPackages //
  janestreetPackages //
  junitPackages //
  kafka-packages //
  lambda-runtime-packages //
  logsPpxPackages //
  menhirPackages //
  morphPackages //
  multicorePackages //
  oidcPackages//
  piafPackages //
  reasonPackages //
  redisPackages //
  sessionPackages //
  subscriptionsTransportWsPackages //
  tyxmlPackages //
  websocketafPackages // {
    arp = osuper.arp.overrideAttrs (_: {
      doCheck = ! stdenv.isDarwin;
    });

    base64 = callPackage ./base64 {
      ocamlPackages = oself;
    };

    bigstring = osuper.bigstring.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = https://github.com/c-cube/ocaml-bigstring/archive/0.3.tar.gz;
        sha256 = "0nipiqarr6d7j2xz9gp5z0pl2x3bs0yg7w7phg10kd7p5sazjrsc";
      };
      doCheck = false;
    });

    calendar = callPackage ./calendar { ocamlPackages = oself; };

    coin = callPackage ./coin { ocamlPackages = oself; };

    containers-data = osuper.containers-data.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [ dune-configurator ];
    });

    ctypes = osuper.ctypes.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocamllabs/ocaml-ctypes/archive/0.17.1.tar.gz;
        sha256 = "1sd74bcsln51bnz11c82v6h6fv23dczfyfqqvv9rxa9wp4p3qrs1";
      };
    });

    cudf = callPackage ./cudf { ocamlPackages = oself; };

    decimal = callPackage ./decimal { ocamlPackages = oself; };

    dose3 = callPackage ./dose3 { ocamlPackages = oself; };

    # Make `dune` effectively be Dune v2.  This works because Dune 2 is
    # backwards compatible.
    dune = if lib.versionOlder "4.07" ocaml.version
      then osuper.dune_2
      else osuper.dune;

    ezgzip = buildDunePackage rec {
      pname = "ezgzip";
      version = "0.2.3";
      src = builtins.fetchurl {
        url = "https://github.com/hcarty/${pname}/archive/v${version}.tar.gz";
        sha256 = "0zjss0hljpy3mxpi1ccdvicb4j0qg5dl6549i23smy1x07pr0nmr";
      };
      propagatedBuildInputs = [rresult astring ocplib-endian camlzip result ];
    };

    ocaml_extlib = osuper.ocaml_extlib.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = "https://ygrek.org/p/release/ocaml-extlib/extlib-1.7.8.tar.gz";
        sha256 = "0npq4hq3zym8nmlyji7l5cqk6drx2rkcx73d60rxqh5g8dla8p4k";
      };
    });

    graphql_ppx = callPackage ./graphql_ppx {
      ocamlPackages = oself;
    };

    hidapi = osuper.hidapi.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [ dune-configurator ];
    });

    irmin = osuper.irmin.overrideAttrs (o: {
      doCheck = false;
      checkInputs = [];
    });
    irmin-http = osuper.irmin-http.overrideAttrs (o: {
      doCheck = false;
    });
    irmin-unix = osuper.irmin-unix.overrideAttrs (o: {
      doCheck = !stdenv.isDarwin;
    });

    janeStreet = janestreetPackages;

    jose = callPackage ./jose { ocamlPackages = oself; };

    ke = osuper.ke.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/mirage/ke/archive/0b3d570f56c558766e8d53600e59ce65f3218556.tar.gz;
        sha256 = "01i20hxjbvzh2i82g8lk44hvnij5gjdlnapcm55balknpflyxv9f";
      };
    });

    luv = callPackage ./luv { ocamlPackages = oself; };

    lwt = osuper.lwt.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocsigen/lwt/archive/5.4.0.tar.gz;
        sha256 = "00wbx1gr38b8pivv1blrzkrwq9qqqq0hbsvkdndcrzyh83q5ypwc";
      };
      buildInputs = o.buildInputs ++ [ dune-configurator ocaml-syntax-shims ];
    });

    magic-mime = callPackage ./magic-mime {
      ocamlPackages = oself;
    };

    merlin = osuper.merlin.overrideAttrs (_: {
      src = dot-merlin-reader.src;
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
      propagatedBuildInputs = [stdlib-shims];
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
        url = https://github.com/OCamlPro/ocp-index/archive/0cac3767d76b3bc8ed9b2854ad01c8015f989b05.tar.gz;
        sha256 = "162q3vvpv60902wvch5v61nky37mqgij7qnlkfv30g0wvpw1gx4a";
      };
    });

    parmap = osuper.parmap.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [ dune-configurator ];
    });

    pbkdf = callPackage ./pbkdf { ocamlPackages = oself; };

    pg_query = callPackage ./pg_query { ocamlPackages = oself; };

    ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };

    postgresql = osuper.postgresql.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [ dune-configurator ];
    });

    ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

    ppxlib = osuper.ppxlib.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.21.0/ppxlib-0.21.0.tbz;
        sha256 = "0gis9qzn3wl4xmvgyzn96i4q4xdayblb3amgb7rm5gr4ilsaz9wf";
      };
      propagatedBuildInputs = [
        # XXX(anmonteiro): this propagates `base` and `stdio` even though
        # ppxlib doesn't depend on them. Many JaneStreet PPXes do, however, and
        # unfortunately they're hard to override without copying everything
        # over (see https://github.com/NixOS/nixpkgs/issues/75485).
        base
        stdio
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
      src = builtins.fetchurl {
        url = https://github.com/savonet/ocaml-ssl/archive/v0.5.10.tar.gz;
        sha256 = "0vcc8p6i8lhs59y3ycikllc6j1adh9syh63g5ibnrp3yz3lk2cwl";
      };

      nativeBuildInputs = [ dune-configurator pkgconfig ];
      propagatedBuildInputs = [ openssl.dev ];
    });

    stdlib-shims = osuper.stdlib-shims.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml/stdlib-shims/releases/download/0.3.0/stdlib-shims-0.3.0.tbz;
        sha256 = "0jnqsv6pqp5b5g7lcjwgd75zqqvcwcl5a32zi03zg1kvj79p5gxs";
      };
    });

    syndic = buildDunePackage rec {
      pname = "syndic";
      version = "1.6.1";
      src = builtins.fetchurl {
        url = "https://github.com/Cumulus/${pname}/releases/download/v${version}/syndic-v${version}.tbz";
        sha256 = "1i43yqg0i304vpiy3sf6kvjpapkdm6spkf83mj9ql1d4f7jg6c58";
      };
      propagatedBuildInputs = [ xmlm uri ptime ];
    };

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

    yuscii = callPackage ./yuscii { ocamlPackages = oself; };
  }
