{ callPackage, fetchzip, fetchFromGitHub, stdenv, pkgconfig, openssl }:

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

    dune_2 = osuper.dune_2.overrideAttrs (o: rec {
      version = "2.1.1";

      src = builtins.fetchurl {
        url = "https://github.com/ocaml/dune/releases/download/${version}/dune-${version}.tbz";
        sha256 = "0z5anyyfiydpk4l45p64k2ravypawnlllixq0h5ir450dw0ifi5i";
      };
    });

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
      buildInputs = [ findlib topkg ];

      buildPhase = "${topkg.run} build --with-js_of_ocaml false";
    });

    dose3 = callPackage ./dose3 { ocamlPackages = oself; };

    cudf = callPackage ./cudf.nix { ocamlPackages = oself; };
  }
