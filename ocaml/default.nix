{ callPackage, libpq, opaline, lib, stdenv, pkgconfig, openssl }:

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

  caqti-packages = callPackage ./caqti {
    ocamlPackages = oself;
  };

  conduit-packages = callPackage ./conduit {
    ocamlPackages = oself;
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

  ipaddrPackages = callPackage ./ipaddr {
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

  menhirPackages = if !stdenv.lib.versionAtLeast osuper.ocaml.version "4.07"
    then {}
    else callPackage ./menhir {
      ocamlPackages = oself;
    };

  morphPackages = callPackage ./morph {
    ocamlPackages = oself;
  };

  opamPackages = callPackage ./opam {
    ocamlPackages = oself;
  };

  piafPackages = callPackage ./piaf { ocamlPackages = oself; };

  reasonPackages = callPackage ./reason {
    ocamlPackages = oself;
  };

  sessionPackages = callPackage ./session {
    ocamlPackages = oself;
  };

  subscriptionsTransportWsPackages = callPackage ./subscriptions-transport-ws {
    ocamlPackages = oself;
  };

  websocketafPackages = callPackage ./websocketaf {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

in
  alcotestPackages //
  archiPackages //
  caqti-packages //
  conduit-packages //
cookiePackages //
  dataloader-packages //
  faradayPackages //
  graphqlPackages //
  glutenPackages //
  h2Packages //
  httpafPackages //
  ipaddrPackages //
  junitPackages //
  kafka-packages //
  lambda-runtime-packages //
  menhirPackages //
  morphPackages //
  opamPackages //
  piafPackages //
  reasonPackages //
  sessionPackages //
  subscriptionsTransportWsPackages //
  websocketafPackages // {
    base64 = callPackage ./base64 {
      ocamlPackages = oself;
    };

    calendar = callPackage ./calendar { ocamlPackages = oself; };

    camlzip = osuper.camlzip.overrideAttrs (o: {
      buildFlags = if stdenv.hostPlatform != stdenv.buildPlatform then
        # TODO: maybe use a patch instead
        "all zip.cmxa"
        else
          o.buildFlags;

      src = builtins.fetchurl {
        url = https://github.com/xavierleroy/camlzip/archive/rel110.tar.gz;
        sha256 = "1ckxf9d19x63crkcn54agn5p77a9s84254s84ig53plh6rriqijz";
      };
    });

    coin = callPackage ./coin { ocamlPackages = oself; };

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
      then oself.dune_2
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

    graphql_ppx = callPackage ./graphql_ppx {
      ocamlPackages = oself;
    };

    jose = callPackage ./jose { ocamlPackages = oself; };

    js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (o: {
      propagatedBuildInputs = o.propagatedBuildInputs ++ [ menhir ];
      src = builtins.fetchurl {
        url = https://github.com/ocsigen/js_of_ocaml/releases/download/3.7.0/js_of_ocaml-3.7.0.tbz;
        sha256 = "0rw6cfkl3zlyav8q2w7grxxqjmg35mz5rgvmkiqb58nl4gmgzx6w";
      };
    });

    ke = osuper.ke.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/mirage/ke/archive/0b3d570f56c558766e8d53600e59ce65f3218556.tar.gz;
        sha256 = "01i20hxjbvzh2i82g8lk44hvnij5gjdlnapcm55balknpflyxv9f";
      };
    });

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

    mirage-kv = buildDunePackage {
      pname = "mirage-kv";
      version = "3.0.1";
      src = builtins.fetchurl {
        url = https://github.com/mirage/mirage-kv/releases/download/v3.0.1/mirage-kv-v3.0.1.tbz;
        sha256 = "1n736sjvdd8rkbc2b5jm9sn0w6hvhjycma5328r0l03v24vk5cki";
      };
      propagatedBuildInputs = [
        lwt
        mirage-device
        fmt
      ];
    };

    mtime = osuper.mtime.override { jsooSupport = false; };

    multipart_form = callPackage ./multipart_form { ocamlPackages = oself; };

    ocaml = osuper.ocaml.override { flambdaSupport = true; };

    uunf = osuper.uunf.overrideAttrs (o: {
      # https://github.com/ocaml/ocaml/issues/9839
      configurePhase = lib.optionalString (lib.versionOlder "4.11" osuper.ocaml.version)
      ''
        ulimit -s 9216
      '';
    });

    ocamlgraph = osuper.ocamlgraph.override { lablgtk = null; };

    ocplib-endian = callPackage ./ocplib-endian { ocamlPackages = oself; };

    pbkdf = callPackage ./pbkdf { ocamlPackages = oself; };

    pecu = callPackage ./pecu { ocamlPackages = oself; };

    pg_query = callPackage ./pg_query { ocamlPackages = oself; };

    ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };

    postgresql = buildDunePackage rec {
      pname = "postgresql";
      version = "4.6.3";
      src = builtins.fetchurl {
        url = "https://github.com/mmottl/postgresql-ocaml/releases/download/${version}/${pname}-${version}.tbz";
        sha256 = "0ya1jl75w8dand9pj1a7sfb0nwi8ll15g5alpvfnn11vn60am01w";
      };
      nativeBuildInputs = [ dune-configurator ];
      propagatedBuildInputs = [ libpq ];
    };

    ppx_cstruct = osuper.ppx_cstruct.overrideAttrs (o: {
      propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_tools_versioned ];
    });

    ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

    ppxlib = osuper.ppxlib.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml-ppx/ppxlib/releases/download/0.20.0/ppxlib-0.20.0.tbz;
        sha256 = "0dxd5inxv12rx9kikl21y384m7cpylyvbjslw69rrpjpy8z91d8w";
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
        url = https://github.com/ocaml-ppx/ppx_deriving/releases/download/v5.2/ppx_deriving-v5.2.tbz;
        sha256 = "1rifvap3pr80qlmhy5swk71lb01wlb1qnv5zcp1m18sch8k2cb8w";
      };
      buildInputs = o.buildInputs ++ [ cppo ];
      propagatedBuildInputs = [ ppxlib result ppx_derivers ];
    });

    ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml-ppx/ppx_deriving_yojson/releases/download/v3.6.1/ppx_deriving_yojson-v3.6.1.tbz;
        sha256 = "1rj4i6l47f7pqr7cfxsfh05i5srb5pp9ns6df9719pbhghhfjbki";
      };
      propagatedBuildInputs = [ ppxlib ppx_deriving yojson ];
    });

    ppx_blob = osuper.ppx_blob.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/johnwhitington/ppx_blob/releases/download/0.7.0/ppx_blob-0.7.0.tbz;
        sha256 = "0r8wsdhjh6ricv85mr8f8a7fkcxzls6dxv6jymy8nykgjvvkb2mc";
      };
    });

    ptime =
      let
        filterJSOO = p:
          !(lib.hasAttr "pname" p && (p.pname == "js_of_ocaml"));
      in
      osuper.ptime.overrideAttrs (o: {
        src = builtins.fetchurl {
          url = https://github.com/dbuenzli/ptime/archive/e85b030c862715eb579b3b902c8eed3f9b985d72.tar.gz;
          sha256 = "0qr6wall0yv1i581anhly46jp34p7q4v011rnr84p9yfj4r6kphp";
        };

        buildInputs = lib.filter filterJSOO o.buildInputs;
        propagatedBuildInputs = lib.filter filterJSOO o.propagatedBuildInputs;
        propagatedNativeBuildInputs = lib.filter filterJSOO (o.propagatedNativeBuildInputs or []);

        buildPhase = "${topkg.run} build --with-js_of_ocaml false";
      });

    rosetta = callPackage ./rosetta { ocamlPackages = oself; };

    routes = callPackage ./routes { ocamlPackages = oself; };

    ssl = osuper.ssl.overrideAttrs (o: {
      version = "0.5.9-dev";
      src = builtins.fetchurl {
        url = https://github.com/savonet/ocaml-ssl/archive/fbffa9b.tar.gz;
        sha256 = "1zf6i4z5aq45in430pagp8cz2q65jdhsdpsgpcdysjm4jlfsswr1";
      };

      nativeBuildInputs = [ dune-configurator pkgconfig ];
      propagatedBuildInputs = [ openssl.dev ];
    });

    stdlib-shims = osuper.stdlib-shims.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml/stdlib-shims/releases/download/0.2.0/stdlib-shims-0.2.0.tbz;
        sha256 = "0nb5flrczpqla1jy2pcsxm06w4jhc7lgbpik11amwhfzdriz0n9c";
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

    tls-mirage = buildDunePackage {
      pname = "tls-mirage";
      version = osuper.tls.version;
      src = osuper.tls.src;
      propagatedBuildInputs = [
        tls
        x509
        fmt
        lwt
        mirage-flow
        mirage-kv
        mirage-clock
        ptime
        mirage-crypto
        mirage-crypto-pk
      ];
    };

    uchar = osuper.uchar.overrideAttrs (o: {
      installPhase = "${opaline}/bin/opaline -libdir $OCAMLFIND_DESTDIR";
      nativeBuildInputs = [ocamlbuild ocaml findlib];
      buildInputs = [ocamlbuild ocaml findlib];
    });

    unstrctrd = callPackage ./unstrctrd { ocamlPackages = oself; };

    utop = osuper.utop.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://github.com/ocaml-community/utop/releases/download/2.7.0/utop-2.7.0.tbz;
        sha256 = "1p9z7jk2dqs7qlgjliz6qhn3dw048hhbr6znyb03qz16vx9sqs70";
      };
    });

    uuuu = callPackage ./uuuu { ocamlPackages = oself; };

    vchan = buildDunePackage {
      pname = "vchan";
      version = "5.0.0";
      src = builtins.fetchurl {
        url = https://github.com/mirage/ocaml-vchan/releases/download/v5.0.0/vchan-v5.0.0.tbz;
        sha256 = "0bx55w0ydl4bdhm6z5v0qj2r59j4avzddhklbb1wx40qvg3adz63";
      };
      propagatedBuildInputs = [
        lwt
        cstruct
        ppx_sexp_conv
        ppx_cstruct
        io-page
        mirage-flow
        xenstore
        xenstore_transport
        sexplib
        cmdliner
      ];
    };

    xenstore = buildDunePackage {
      pname = "xenstore";
      version = "2.1.0";
      src = builtins.fetchurl {
        url = https://github.com/mirage/ocaml-xenstore/releases/download/2.1.1/xenstore-2.1.1.tbz;
        sha256 = "1xc49j3n3jap2n3w7v6a9q08a4bw5xxv3z4wsp24bhxd47m18f18";
      };
      propagatedBuildInputs = [
        cstruct
        ppx_cstruct
        lwt
      ];
    };

    xenstore_transport = buildDunePackage (rec {
      pname = "xenstore_transport";
      version = "1.1.0";
      src = builtins.fetchurl {
        url = "https://github.com/xapi-project/ocaml-xenstore-clients/archive/v${version}.tar.gz";
        sha256 = "1lggdxw1ai66irmnzn9rifz2ksbvngsfi2rc0xz4d8wph1y2yzlv";
      };
      propagatedBuildInputs = [
        lwt
        xenstore
      ];
    });

    yojson = buildDunePackage {
      pname = "yojson";
      version = "1.7.0";
      src = builtins.fetchurl {
        url = https://github.com/ocaml-community/yojson/releases/download/1.7.0/yojson-1.7.0.tbz;
        sha256 = "1iich6323npvvs8r50lkr4pxxqm9mf6w67cnid7jg1j1g5gwcvv5";
      };

      propagatedNativeBuildInputs = [ cppo ];
      propagatedBuildInputs = [ easy-format biniou ];
    };

    yuscii = callPackage ./yuscii { ocamlPackages = oself; };

    zed = callPackage ./zed {
      ocamlPackages = oself;
    };
  }
