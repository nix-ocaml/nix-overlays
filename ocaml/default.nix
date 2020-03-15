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

  janeStreetPackages = osuper.janeStreet // (callPackage ./janestreet {
    inherit osuper oself;
  });

  junitPackages = callPackage ./junit {
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

  opamPackages = callPackage ./opam {
    ocamlPackages = oself;
  };

  websocketafPackages = callPackage ./websocketaf {
    ocamlPackages = oself;
  };

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
  janeStreetPackages //
  junitPackages // {
    alcotest = osuper.alcotest.overrideAttrs (o: {
      version = "1.0.1";
      src = builtins.fetchurl {
        url = https://github.com/mirage/alcotest/releases/download/1.0.1/alcotest-1.0.1.tbz;
        sha256 = "1xlklxb83gamqbg8j5dzm5jk4mvcwkspxajh93p6vpw9ia1li1qc";
      };
      propagatedBuildInputs = lib.remove result o.propagatedBuildInputs ++ [ re ];
    });

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

    cudf = callPackage ./cudf { ocamlPackages = oself; };

    digestif = osuper.digestif.overrideAttrs (o: {
      # Don't run tests for digestif because it contains duplicate test names
      # (Incompatible with alcotest v1)
      doCheck = false;
    });

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

    fmt = osuper.fmt.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = https://erratique.ch/software/fmt/releases/fmt-0.8.8.tbz;
        sha256 = "1iy0rwknd302mr15328g805k210xyigxbija6fzqqfzyb43azvk4";
      };
      buildInputs = [ findlib topkg cmdliner ];
      propagatedBuildInputs = [uchar seq stdlib-shims];
    });

    graphql_ppx = callPackage ./graphql_ppx {
      ocamlPackages = oself;
    };

    janePackage = osuper.janePackage.override {
      defaultVersion = "0.13.0";
    };

    janeStreet = janeStreetPackages;

    jose = callPackage ./jose { ocamlPackages = oself; };

    lambdasoup = osuper.lambdasoup.overrideAttrs (o: rec {
      version = "0.7.0";
      src = fetchFromGitHub {
        owner = "aantron";
        repo = "lambdasoup";
        rev = version;
        sha256 = "0wivjg4z8w7yr9jlkklx387gs8qdf1wv8pf86mkc4p50735hzaqk";
      };
    });

    lwt4 = osuper.lwt4.overrideAttrs (o: rec {
      version = "5.2.0";

      src = fetchzip {
        url = "https://github.com/ocsigen/${o.pname}/archive/${version}.tar.gz";
        sha256 = "1znw8ckwdmqsnrcgar4g33zgr659l4l904bllrz69bbwdnfmz2x3";
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

    magic-mime = callPackage ./magic-mime {
      ocamlPackages = oself;
    };

    markup = callPackage ./markup {
      ocamlPackages = oself;
    };

    nocrypto = callPackage ./nocrypto { ocamlPackages = oself; };

    ocaml-migrate-parsetree = osuper.ocaml-migrate-parsetree.overrideAttrs (o: {
      version = "1.6.0";
      src = builtins.fetchurl {
        url = https://github.com/ocaml-ppx/ocaml-migrate-parsetree/releases/download/v1.6.0/ocaml-migrate-parsetree-v1.6.0.tbz;
        sha256 = "0gz39m4c4cbpza3sjfh4dfxlxf17r7bpqaxqq1zy2k0i4myqw0cv";
      };
    });

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

    ppxfind = callPackage ./ppxfind { ocamlPackages = oself; };

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

    reason = callPackage ./reason { ocamlPackages = oself; };

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

    yaml = osuper.yaml.overrideAttrs (o: rec {
      version = "2.1.0";
      src = fetchFromGitHub {
        owner = "avsm";
        repo = "ocaml-yaml";
        rev = "v${version}";
        sha256 = "141h1zbg7gfw0424fkq3n5jhsccrky9mmgz42qmnm51m2d87xss3";
      };
    });

    zed = callPackage ./zed {
      ocamlPackages = oself;
    };
  }
