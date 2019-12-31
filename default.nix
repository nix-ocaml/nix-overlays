# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv pkgs;
  buildPkg = { pkgName, src, ... }@args: pkgs.ocamlPackages.buildDunePackage ({
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
    src = pkgs.fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "faraday";
      rev = "8d37f20";
      sha256 = "1g9k5lyg6qck375l29dsid0q24i8j6m0jhsxrf460w2gxm4xl754";
    }; } // args);

  buildHttpaf = { pkgName, ... }@args: buildPkg ({
    version = "0.6.5-dev";
    src = pkgs.fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "3daf1f899135880ff253f9f09d80d84f29990f1e";
      sha256 = "1yhkv92s5hgky2ldmc0jinrnz1h2gnkzglzg327rvlrvrlymwrgp";
    };

    propagatedBuildInputs = with self.ocamlPackages; [ angstrom faraday ];
  } // args);

  buildH2Repo = { pkgName, ... }@args: buildPkg ({
    version = "0.5.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "75d2a2e";
      sha256 = "1zw1y01paahy38y204alsqvvj4yqv4wzjkxrd203dd2r8n0l5pyk";
    };

    propagatedBuildInputs = with self.ocamlPackages; [ angstrom faraday ];
  } // args);

in
  {
    ocamlPackages = super.ocaml-ng.ocamlPackages_4_09.overrideScope' (selfO: superO: {
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

      httpaf = buildHttpaf { pkgName = "httpaf"; };
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
      };

      h2 = buildH2Repo {
        pkgName = "h2";
        propagatedBuildInputs = with selfO; [ base64 psq hpack httpaf ];
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

        nativeBuildInputs = with super.pkgs; [ pkgconfig ];
        propagatedBuildInputs = with super.pkgs; [
          openssl
        ];
      };

      ezgzip = buildPkg {
        pkgName = "ezgzip";
        version = "0.2.3";
        src = pkgs.fetchFromGitHub {
          owner = "hcarty";
          repo = "ezgzip";
          rev = "v0.2.3";
          sha256 = "0x2i40n289k4gn2hn2hrmh6z9j570nbim368iddy54aqb97hj3ir";
        };
        buildInputs = with selfO; [rresult];
        propagatedBuildInputs = with selfO; [ astring ocplib-endian camlzip ];
      };
    });
  }

