{ callPackage , postgresql , opaline , lib , fetchzip,
  fetchFromGitHub , stdenv , pkgconfig , openssl }:

oself: osuper:

with oself;

let
  archiPackages = callPackage ./archi {
    ocamlPackages = oself;
    ocamlVersion = osuper.ocaml.version;
  };

  caqti-packages = callPackage ./caqti {
    ocamlPackages = oself;
  };

  faradayPackages = callPackage ./faraday {
    ocamlPackages = oself;
  };

  graphqlPackages = callPackage ./graphql {
    ocamlPackages = oself;
  };

  h2Packages = callPackage ./h2 {
    ocamlPackages = oself;
  };

  httpafPackages = callPackage ./httpaf {
    ocamlPackages = oself;
  };

  lambda-runtime-packages = callPackage ./lambda-runtime {
    ocamlPackages = oself;
  };

  menhirPackages = callPackage ./menhir {
    ocamlPackages = oself;
  };

  opamPackages = callPackage ./opam {
    ocamlPackages = oself;
  };

  websocketafPackages = callPackage ./websocketaf {
    ocamlPackages = oself;
  };

  janeStreetPackages = osuper.janeStreet // (callPackage ./janestreet {
    inherit osuper oself;
  });

in
  archiPackages //
  caqti-packages //
  faradayPackages //
  graphqlPackages //
  h2Packages //
  httpafPackages //
  lambda-runtime-packages //
  menhirPackages //
  opamPackages //
  websocketafPackages //
  janeStreetPackages // {
    calendar = callPackage ./calendar { ocamlPackages = oself; };

    camlzip = osuper.camlzip.overrideAttrs (o: {
      buildFlags = if stdenv.hostPlatform != stdenv.buildPlatform then
        # TODO: maybe use a patch instead
        "all zip.cmxa"
        else
          o.buildFlags;

      src = builtins.fetchurl {
        url = "https://github.com/xavierleroy/camlzip/archive/rel110.tar.gz";
        sha256 = "1ckxf9d19x63crkcn54agn5p77a9s84254s84ig53plh6rriqijz";
      };
    });

    cudf = callPackage ./cudf { ocamlPackages = oself; };

    dose3 = callPackage ./dose3 { ocamlPackages = oself; };

    ezgzip = buildDunePackage rec {
      pname = "ezgzip";
      version = "0.2.3";
      src = fetchFromGitHub {
        owner = "hcarty";
        repo = pname;
        rev = "v${version}";
        sha256 = "0x2i40n289k4gn2hn2hrmh6z9j570nbim368iddy54aqb97hj3ir";
      };
      propagatedBuildInputs = [rresult astring ocplib-endian camlzip result ];
    };

    janePackage = osuper.janePackage.override {
      defaultVersion = "0.13.0";
    };

    janeStreet = janeStreetPackages;

    jose = callPackage ./jose { ocamlPackages = oself; };

    lwt4 = osuper.lwt4.overrideAttrs (o: rec {
      version = "5.1.1";

      src = fetchzip {
        url = "https://github.com/ocsigen/${o.pname}/archive/${version}.tar.gz";
        sha256 = "1nl7rdnwfdhwcsm5zpay1nr9y5cbapd9x1qzily7zk9ab4v52m8g";
      };
    });

    lwt_ppx = osuper.lwt_ppx.overrideAttrs (o: {
      pname = "lwt_ppx";
      version = "1.2.4";

      src = fetchzip {
        url = "https://github.com/ocsigen/lwt/archive/4.4.0.tar.gz";
        sha256 = "1l97zdcql7y13fhaq0m9n9xvxf712jg0w70r72fvv6j49xm4nlhi";
      };
    });

    nocrypto = callPackage ./nocrypto { ocamlPackages = oself; };

    pg_query = callPackage ./pg_query { ocamlPackages = oself; };

    ppx_rapper = callPackage ./ppx_rapper { ocamlPackages = oself; };

    piaf = callPackage ./piaf { ocamlPackages = oself; };

    postgresql = buildDunePackage rec {
      pname = "postgresql";
      version = "4.5.2-dev";
      src = builtins.fetchurl {
        url = "https://github.com/mmottl/${pname}-ocaml/archive/eb8db696ba5c7b44c704be2ec5d4ca56f27b65cf.tar.gz";
        sha256 = "0gib9l4rhy4djxhl2v59nvd0zy6gljr91m2gn3h6hpnmylkgn1kf";
      };
      nativeBuildInputs = [ dune-configurator base stdio ];
      propagatedBuildInputs = [ postgresql ];
    };

    ppxlib = osuper.ppxlib.overrideAttrs (o: {
      src = fetchFromGitHub {
        owner = "ocaml-ppx";
        repo = "ppxlib";
        rev = "f13dc352b9bb17e8ced3d12d2533cffba2fcbfac";
        sha256 = "1cg0is23c05k1rc94zcdz452p9zn11dpqxm1pnifwx5iygz3w0a1";
      };
    });

    ptime = osuper.ptime.overrideAttrs (o: {
      buildInputs = lib.remove js_of_ocaml o.buildInputs;

      buildPhase = "${topkg.run} build --with-js_of_ocaml false";
    });

    reason = osuper.reason.overrideAttrs (o: {
      src = fetchFromGitHub {
        owner = "facebook";
        repo = "reason";
        rev = "ede1f25c895ac9c6a93f7d3c87a19eaa8de366f0";
        sha256 = "04v8sk29051f897pliwaip1v57s85fb9m6h2bsx4a0wb8y30rmxx";
      };
      propagatedBuildInputs = o.propagatedBuildInputs ++ [ fix ];
    });

    routes = callPackage ./routes { ocamlPackages = oself; };

    ssl = osuper.ssl.overrideAttrs (o: {
      version = "0.5.9-dev";
      src = fetchFromGitHub {
        owner = "savonet";
        repo = "ocaml-ssl";
        rev = "fbffa9b";
        sha256 = "1pp9hig7kkzhr3n1rkc177mnahrijx6sbq59xjr8bnbfsmn1l2ay";
      };

      nativeBuildInputs = [ dune pkgconfig ];
      propagatedBuildInputs = [ openssl.dev ];
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

    uchar = osuper.uchar.overrideAttrs (o: {
      installPhase = "${opaline}/bin/opaline -libdir $OCAMLFIND_DESTDIR";
      nativeBuildInputs = [ocamlbuild ocaml findlib];
      buildInputs = [ocamlbuild ocaml findlib];
    });

    uri = osuper.uri.overrideAttrs (o: {
      src = fetchFromGitHub {
        owner = "anmonteiro";
        repo = "ocaml-uri";
        rev = "72fce0fc74a6382f4c773382dd123143f1471522";
        sha256 = "1iv1wqx7rqca36i2whicabd7b7mwdprcbs6miza960rfsrxmzr7i";
      };
      propagatedBuildInputs = o.propagatedBuildInputs ++ [ angstrom ];
    });
  }
