{ callPackage, opaline, lib, fetchzip, fetchFromGitHub, stdenv, pkgconfig, openssl }:

oself: osuper:

with oself;

let
  faradayPackages = callPackage ./faraday.nix {
    ocamlPackages = oself;
  };
  httpafPackages = callPackage ./httpaf.nix {
    ocamlPackages = oself;
  };

  h2Packages = callPackage ./h2.nix {
    ocamlPackages = oself;
  };

  opamPackages = callPackage ./opam.nix {
    ocamlPackages = oself;
  };

  lambda-runtime-packages = callPackage ./lambda-runtime.nix {
    ocamlPackages = oself;
  };

in
  opamPackages //
  faradayPackages //
  httpafPackages //
  h2Packages //
  lambda-runtime-packages // {
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

    piaf = callPackage ./piaf.nix { ocamlPackages = oself; };

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

    camlzip = osuper.camlzip.overrideAttrs (o: {
      buildFlags = if stdenv.hostPlatform != stdenv.buildPlatform then
        "all zip.cmxa"
        else
          o.buildFlags;

      src = builtins.fetchurl {
        url = "https://github.com/xavierleroy/camlzip/archive/rel110.tar.gz";
        sha256 = "1ckxf9d19x63crkcn54agn5p77a9s84254s84ig53plh6rriqijz";
      };
    });

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

    syndic = buildDunePackage rec {
      pname = "syndic";
      version = "1.6.1";
      src = builtins.fetchurl {
        url = "https://github.com/Cumulus/${pname}/releases/download/v${version}/syndic-v${version}.tbz";
        sha256 = "1i43yqg0i304vpiy3sf6kvjpapkdm6spkf83mj9ql1d4f7jg6c58";
      };
      propagatedBuildInputs = [ xmlm uri ptime ];
    };

    ptime = osuper.ptime.overrideAttrs (o: {
      buildInputs = lib.remove js_of_ocaml o.buildInputs;

      buildPhase = "${topkg.run} build --with-js_of_ocaml false";
    });

    ppxlib = osuper.ppxlib.overrideAttrs (o: {
      src = fetchFromGitHub {
        owner = "ocaml-ppx";
        repo = "ppxlib";
        rev = "f13dc352b9bb17e8ced3d12d2533cffba2fcbfac";
        sha256 = "1cg0is23c05k1rc94zcdz452p9zn11dpqxm1pnifwx5iygz3w0a1";
      };
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

    dose3 = callPackage ./dose3 { ocamlPackages = oself; };

    cudf = callPackage ./cudf.nix { ocamlPackages = oself; };

    uchar = osuper.uchar.overrideAttrs (o: {
      installPhase = "${opaline}/bin/opaline -libdir $OCAMLFIND_DESTDIR";
      nativeBuildInputs = [ocamlbuild ocaml findlib];
      buildInputs = [ocamlbuild ocaml findlib];
    });
  }
