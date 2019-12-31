{ lib, pkgs, fetchFromGitHub, stdenv, ocamlPackages }:

let
  buildPkg = { pkgName, src, ... }@args: ocamlPackages.buildDunePackage ({
    inherit (args) version;
    pname = pkgName;

    src = src;

    doCheck = false;

    meta = {
      description = "A high-performance, memory-efficient, and scalable web server for OCaml";
      license = stdenv.lib.licenses.bsd3;
    };
  } // args);

  buildFaraday = { pkgName, ... }@args: buildPkg ({
    version = "0.12.0-dev";
    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "faraday";
      rev = "8d37f20";
      sha256 = "1g9k5lyg6qck375l29dsid0q24i8j6m0jhsxrf460w2gxm4xl754";
    }; } // args);

  buildHttpaf = { pkgName, ... }@args: buildPkg ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "3daf1f899135880ff253f9f09d80d84f29990f1e";
      sha256 = "1yhkv92s5hgky2ldmc0jinrnz1h2gnkzglzg327rvlrvrlymwrgp";
    };
  } // args);

  buildH2Repo = { pkgName, ... }@args: buildPkg ({
    version = "0.5.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "75d2a2e";
      sha256 = "1zw1y01paahy38y204alsqvvj4yqv4wzjkxrd203dd2r8n0l5pyk";
    };
  } // args);

in
  ocamlPackages.overrideScope' (selfO: superO: {
    faraday = buildFaraday {
      pkgName = "faraday";
      propagatedBuildInputs = with selfO; [ bigstringaf ];
    };

    faraday-lwt = buildFaraday {
      pkgName = "faraday-lwt";
      propagatedBuildInputs = with selfO; [ faraday lwt4 ];
    };

    faraday-lwt-unix = buildFaraday {
      pkgName = "faraday-lwt-unix";
      propagatedBuildInputs = with selfO; [ faraday-lwt ];
    };

    httpaf = buildHttpaf {
      pkgName = "httpaf";
      propagatedBuildInputs = with selfO; [ angstrom faraday ];
    };

    httpaf-lwt = buildHttpaf {
      pkgName = "httpaf-lwt";
      propagatedBuildInputs = with selfO; [ httpaf lwt4 ];
    };

    httpaf-lwt-unix = buildHttpaf {
      pkgName = "httpaf-lwt-unix";
      propagatedBuildInputs = with selfO; [
        httpaf
        httpaf-lwt
        faraday-lwt-unix
        lwt_ssl
      ];
    };

    hpack = buildH2Repo {
      pkgName = "hpack";
      propagatedBuildInputs = with selfO; [ angstrom faraday ];
    };

    h2 = buildH2Repo {
      pkgName = "h2";
      propagatedBuildInputs = with selfO; [
        angstrom
        faraday
        base64
        psq
        hpack
        httpaf
      ];
    };

    h2-lwt = buildH2Repo {
      pkgName = "h2-lwt";
      propagatedBuildInputs = with selfO; [ h2 lwt4 ];
    };

    h2-lwt-unix = buildH2Repo {
      pkgName = "h2-lwt-unix";
      propagatedBuildInputs = with selfO; [
        h2-lwt
        faraday-lwt-unix
        lwt_ssl
      ];
    };

    ssl = buildPkg {
      pkgName = "ssl";
      version = "0.5.9-dev";
      src = pkgs.fetchFromGitHub {
        owner = "savonet";
        repo = "ocaml-ssl";
        rev = "fbffa9b";
        sha256 = "1pp9hig7kkzhr3n1rkc177mnahrijx6sbq59xjr8bnbfsmn1l2ay";
      };

      nativeBuildInputs = with pkgs; [ pkgconfig ];
      propagatedBuildInputs = with pkgs; [
        openssl
      ];
    };

    camlzip = lib.overrideDerivation superO.camlzip (_: {
      inherit (superO) camlzip;

      src = pkgs.fetchurl {
        url = "https://github.com/xavierleroy/camlzip/archive/rel110.tar.gz";
        sha256 = "1ckxf9d19x63crkcn54agn5p77a9s84254s84ig53plh6rriqijz";
      };

    });

    ezgzip = buildPkg {
      pkgName = "ezgzip";
      version = "0.2.3-dev";
      src = pkgs.fetchFromGitHub {
        owner = "anmonteiro";
        repo = "ezgzip";
        rev = "0719eb0";
        sha256 = "07kihdwrb5sj8j15yccb6msq3kgca7lv6xmhjrgh7j2cc6nkfnsh";
      };
      propagatedBuildInputs = with selfO; [rresult astring ocplib-endian camlzip  ];
    };
  })
