{ darwin, fetchFromGitHub, oself }:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

  caqti-eio = buildDunePackage {
    inherit (caqti) version src;
    pname = "caqti-eio";
    postPatch = ''
      substituteInPlace caqti-eio/lib/dune --replace "logs" "logs eio_main"
      substituteInPlace \
        caqti-eio/lib/system.ml caqti-eio/lib/caqti_eio.mli \
        caqti-eio/lib-unix/caqti_eio_unix.mli \
        --replace "Eio.Stdenv.t" "Eio_unix.Stdenv.base"

      substituteInPlace caqti-eio/lib/system.ml \
        --replace \
          'fork_sub ~sw ~on_error:(fun _ -> ()) (fun _sw -> f ())' \
          'fork ~sw (fun () -> (Switch.run (fun _sw -> f ())))'
    '';
    propagatedBuildInputs = [ eio eio_main caqti ];
  };

  eio-ssl = callPackage ./eio-ssl { };

  gluten-eio = callPackage ./gluten/eio.nix { };

  h2-eio = callPackage ./h2/eio.nix { };

  httpaf-eio = callPackage ./httpaf/eio.nix { };

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

  piaf = callPackage ./piaf { stdenv = darwin.apple_sdk_11_0.stdenv; };
  carl = callPackage ./piaf/carl.nix { };

  ppx_rapper_eio = callPackage ./ppx_rapper/eio.nix { };


  qcheck-multicoretests-util = buildDunePackage {
    pname = "qcheck-multicoretests-util";
    version = "0.2";

    src = fetchFromGitHub {
      owner = "ocaml-multicore";
      repo = "multicoretests";
      rev = "0.2";
      hash = "sha256-U1ZqfWMwpAvbPq5yp2U9YTFklT4MypzTSfNvcKJfaYE=";
    };
    propagatedBuildInputs = [ qcheck-core ];
  };
  qcheck-lin = buildDunePackage {
    pname = "qcheck-lin";
    inherit (qcheck-multicoretests-util) src version;
    propagatedBuildInputs = [ qcheck-core qcheck-multicoretests-util ];
  };
  qcheck-stm = buildDunePackage {
    pname = "qcheck-stm";
    inherit (qcheck-multicoretests-util) src version;
    propagatedBuildInputs = [ qcheck-core qcheck-multicoretests-util ];
  };

  runtime_events_tools = buildDunePackage {
    pname = "runtime_events_tools";
    version = "0.4.0";

    src = builtins.fetchurl {
      url = https://github.com/tarides/runtime_events_tools/releases/download/0.4.0/runtime_events_tools-0.4.0.tbz;
      sha256 = "185gyw4p9i4bjav0y3ighbnmsaidlc4szni4qpmafk8rx10by9j9";
    };

    propagatedBuildInputs = [ tracing cmdliner hdr_histogram ];
  };

  saturn = buildDunePackage {
    pname = "saturn";

    inherit (saturn_lockfree) src version;

    propagatedBuildInputs = [ domain-shims saturn_lockfree ];
  };

  saturn_lockfree = buildDunePackage {
    pname = "saturn_lockfree";
    version = "0.0.4";

    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/saturn/releases/download/0.4.0/saturn-0.4.0.tbz;
      sha256 = "1yw86yimwq5q6aji3i8vsrx9nz58qv0zqh1mm0db8mbhlaayqyvw";
    };

    propagatedBuildInputs = [ domain-shims ];
  };

  tls-eio = buildDunePackage {
    pname = "tls-eio";
    inherit (tls) version src;
    propagatedBuildInputs = [ tls mirage-crypto-rng mirage-crypto-rng-eio x509 eio ];
  };

  websocketaf-eio = callPackage ./websocketaf/eio.nix { };
}
