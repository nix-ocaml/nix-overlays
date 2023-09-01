{ darwin, fetchFromGitHub, oself }:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

  caqti-eio = buildDunePackage {
    inherit (caqti) version src;
    pname = "caqti-eio";
    propagatedBuildInputs = [ eio eio_main caqti ];
  };

  domain-local-timeout = buildDunePackage {
    pname = "domain-local-timeout";
    version = "1.0.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/domain-local-timeout/releases/download/1.0.0/domain-local-timeout-1.0.0.tbz;
      sha256 = "0m98gvj2l2l23v811zsdgyw86dbz3k1diz3lywxch6rl6jg72bwa";
    };
    propagatedBuildInputs = [ mtime psq thread-table ];
  };

  cohttp-eio = buildDunePackage {
    pname = "cohttp-eio";
    inherit (http) src version;
    doCheck = false;
    propagatedBuildInputs = [ cohttp eio_main ptime ];
  };

  eio-ssl = callPackage ./eio-ssl { };

  gluten-eio = callPackage ./gluten/eio.nix { };

  h2-eio = callPackage ./h2/eio.nix { };

  httpaf-eio = callPackage ./httpaf/eio.nix { };



  irmin-eio = buildDunePackage {
    pname = "irmin";

    version = "2023-08-25+eio";

    src = fetchFromGitHub {
      owner = "mirage";
      repo = "irmin";
      rev = "5eb94d774e505ee9f870bbfdbc799b07439a489d";
      sha256 = "sha256-LXA2Io5Cq/s6Ym4zp6Q/4rvtAzie17gwpbE2viJN6QM=";
    };

    propagatedBuildInputs = with oself; [
      repr
      fmt
      uri
      uutf
      jsonm
      eio
      lwt
      digestif
      ocamlgraph
      logs
      bheap
      astring
      mtime
      bigstringaf
      ppx_irmin
    ];

    checkInputs = with oself; [
      hex
      alcotest
      eio_main
      qcheck-alcotest
      vector
      bisect_ppx
    ];

    doCheck = true;
  };

  irmin-eio-fs = buildDunePackage {
    pname = "irmin-fs";
    inherit (oself.irmin-eio) version src;

    propagatedBuildInputs = with oself; [
      irmin-eio
      astring
      logs
      eio
      lwt
    ];

    # need to package more before we can do this
    doCheck = false;
  };

  irmin-eio-pack = buildDunePackage {
    pname = "irmin-pack";
    inherit (oself.irmin-eio) version src;

    propagatedBuildInputs = with oself; [
      irmin-eio
      ppx_irmin
      index
      fmt
      logs
      eio
      mtime
      cmdliner
      optint
      checkseum
      rusage
    ];

    checkInputs = [
      astring
      alcotest
    ];

    # need to package more before we can do this
    doCheck = false;
  };

  kafka-eio = buildDunePackage {
    pname = "kafka-eio";
    inherit (kafka) hardeningDisable version src;
    propagatedBuildInputs = [ eio kafka ];
  };

  kcas = callPackage ./kcas { };
  kcas_data = callPackage ./kcas/data.nix { };

  lambda-runtime = callPackage ./lambda-runtime { };
  vercel = callPackage ./lambda-runtime/vercel.nix { };

  lwt_domain = callPackage ./lwt/domain.nix { };

  lwt_eio = callPackage ./eio/lwt_eio.nix { };

  mirage-crypto-rng-eio = buildDunePackage {
    pname = "mirage-crypto-rng-eio";
    inherit (mirage-crypto) src version;
    propagatedBuildInputs = [ eio mirage-crypto-rng ];
  };

  moonpool = buildDunePackage {
    pname = "moonpool";
    version = "0.4";
    src = builtins.fetchurl {
      url = https://github.com/c-cube/moonpool/releases/download/v0.4/moonpool-0.4.tbz;
      sha256 = "0zzmgp9dib1aqkpfqhypikv5jvqva3bnv6sh969ms6psblrxqkkg";
    };

    propagatedBuildInputs = [ either ];
  };

  multicore-magic = buildDunePackage {
    pname = "multicore-magic";
    version = "2.0.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/multicore-magic/releases/download/2.0.0/multicore-magic-2.0.0.tbz;
      sha256 = "0bg045f0b7jj6wywivnl5g84hngcm69gs4vchk31xxy7d3yx7lav";
    };
  };

  piaf = callPackage ./piaf { stdenv = darwin.apple_sdk_11_0.stdenv; };
  carl = callPackage ./piaf/carl.nix { };

  ppx_rapper_eio = callPackage ./ppx_rapper/eio.nix { };

  runtime_events_tools = buildDunePackage {
    pname = "runtime_events_tools";
    version = "0.4.0";

    src = builtins.fetchurl {
      url = https://github.com/tarides/runtime_events_tools/releases/download/0.4.0/runtime_events_tools-0.4.0.tbz;
      sha256 = "185gyw4p9i4bjav0y3ighbnmsaidlc4szni4qpmafk8rx10by9j9";
    };

    propagatedBuildInputs = [ tracing cmdliner hdr_histogram ];
  };

  tls-eio = buildDunePackage {
    pname = "tls-eio";
    inherit (tls) version src;
    propagatedBuildInputs = [ tls mirage-crypto-rng mirage-crypto-rng-eio x509 eio ];
  };

  websocketaf-eio = callPackage ./websocketaf/eio.nix { };
}
