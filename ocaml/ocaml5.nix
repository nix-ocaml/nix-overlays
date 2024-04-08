{ darwin, fetchFromGitHub, oself, osuper }:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

  backoff = buildDunePackage {
    pname = "backoff";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/backoff/releases/download/0.1.0/backoff-0.1.0.tbz;
      sha256 = "0013ikss0nq6yi8yjpkx67qnnpb3g6l8m386vqsd344y49war90i";
    };
  };

  caqti-eio = buildDunePackage {
    inherit (caqti) version src;
    pname = "caqti-eio";
    propagatedBuildInputs = [ eio eio_main caqti ];
  };

  cohttp-eio = buildDunePackage {
    pname = "cohttp-eio";
    inherit (http) src version;
    doCheck = false;
    propagatedBuildInputs = [ cohttp eio_main ptime ];
  };

  eio-ssl = callPackage ./eio-ssl { };

  graphql-eio = buildDunePackage {
    pname = "graphql-eio";
    inherit (graphql_parser) src version;
    propagatedBuildInputs = [ eio_main graphql ];
  };

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

  miou = buildDunePackage {
    pname = "miou";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://github.com/robur-coop/miou/releases/download/v0.1.0/miou-0.1.0.tbz;
      sha256 = "04d66vbfw3hwx50dwk42256w1nk8f2aj21m7q3s5zkzqv0pklfsr";
    };
    doCheck = true;
    checkInputs = [ dscheck fmt ];
  };

  moonpool = buildDunePackage {
    pname = "moonpool";
    version = "0.6";
    src = builtins.fetchurl {
      url = https://github.com/c-cube/moonpool/releases/download/v0.6/moonpool-0.6.tbz;
      sha256 = "0cvnbv30nmpv7zpq9vfa3sz5wi1wxqm578mnga6blyx3h9f0kz9y";
    };

    propagatedBuildInputs = [ either ];
    doCheck = true;
    nativeCheckInputs = [ mdx ];
    checkInputs = [ mdx qcheck-core trace trace-tef ];
  };

  multicore-magic = buildDunePackage {
    pname = "multicore-magic";
    version = "2.0.0";
    src = builtins.fetchurl {
      url = https://github.com/ocaml-multicore/multicore-magic/releases/download/2.1.0/multicore-magic-2.1.0.tbz;
      sha256 = "0i2if0vxj2np5qp5js6lgsc130fwz7vgf1rly9q34h0bfdj47zr4";
    };
  };

  piaf = callPackage ./piaf { };
  carl = callPackage ./piaf/carl.nix { };

  ppx_rapper_eio = callPackage ./ppx_rapper/eio.nix { };

  runtime_events_tools = buildDunePackage {
    pname = "runtime_events_tools";
    version = "0.5.0";

    src = builtins.fetchurl {
      url = https://github.com/tarides/runtime_events_tools/releases/download/0.5.1/runtime_events_tools-0.5.1.tbz;
      sha256 = "0r35cpbmj17ldpfkf4dzk4bs1knfy4hyjz6ax0ayrck25rm397dh";
    };

    propagatedBuildInputs = [ tracing cmdliner hdr_histogram ];
  };

  tls-eio = buildDunePackage {
    pname = "tls-eio";
    inherit (tls) version src;
    propagatedBuildInputs = [ tls mirage-crypto-rng mirage-crypto-rng-eio x509 eio ];
  };

  wayland = osuper.wayland.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/talex5/ocaml-wayland/releases/download/v2.0/wayland-2.0.tbz;
      sha256 = "0jw3x66yscl77w17pp31s4vhsba2xk6z2yvb30fvh0vd9p7ba8c8";
    };
    propagatedBuildInputs = [ eio ];
    checkInputs = o.checkInputs ++ [ eio_main ];
  });

  websocketaf-eio = callPackage ./websocketaf/eio.nix { };
}
