{ darwin, fetchFromGitHub, nodejs_latest, oself, osuper }:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

  backoff = buildDunePackage {
    pname = "backoff";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/backoff/releases/download/0.1.0/backoff-0.1.0.tbz";
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

  httpun-eio = callPackage ./httpun/eio.nix { };
  httpaf-eio = httpun-eio;

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
    version = "0.6";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/moonpool/releases/download/v0.6/moonpool-0.6.tbz";
      sha256 = "0cvnbv30nmpv7zpq9vfa3sz5wi1wxqm578mnga6blyx3h9f0kz9y";
    };

    propagatedBuildInputs = [ either ];
    doCheck = false;
    nativeCheckInputs = [ mdx ];
    checkInputs = [ mdx qcheck-core trace trace-tef ];
  };

  multicore-bench = buildDunePackage {
    pname = "multicore-bench";
    version = "0.1.2";
    src = builtins.fetchurl {
      url =
        "https://github.com/ocaml-multicore/multicore-bench/releases/download/0.1.2/multicore-bench-0.1.2.tbz";
      sha256 = "1cj3wvawk4rxbgcy1cj3pj421jafg5xz18ff93wa1040cz01c975";
    };
    propagatedBuildInputs = [ yojson mtime domain-local-await multicore-magic ];
    doCheck = true;
    nativeCheckInputs = [ mdx ];
    checkInputs = [ backoff mdx ];
  };

  multicore-magic = buildDunePackage {
    pname = "multicore-magic";
    version = "2.2.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/multicore-magic/releases/download/2.2.0/multicore-magic-2.2.0.tbz";
      sha256 = "1a86lzqv8cv3jw64ijzlnm1qx2ynyy8ixrwyazdija1g58c6b2zk";
    };
  };

  piaf = callPackage ./piaf { };
  carl = callPackage ./piaf/carl.nix { };

  picos = buildDunePackage {
    pname = "picos";
    version = "0.3.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/picos/releases/download/0.3.0/picos-0.3.0.tbz";
      sha256 = "0rphlxacn9n3zpvy6v2s7v26ph6pzvgff11gz1j9gcp4pp008j2l";
    };
    propagatedBuildInputs = [
      multicore-magic
      backoff
      thread-local-storage
      lwt
      mtime
      psq
    ];

    doCheck = true;
    nativeCheckInputs = [ mdx nodejs_latest js_of_ocaml ];
    checkInputs = [
      multicore-bench
      alcotest
      qcheck-core
      qcheck-stm
      qcheck-multicoretests-util
      mdx
      ocaml-version
      domain_shims
      js_of_ocaml
      dscheck
    ];
  };

  ppx_rapper_eio = callPackage ./ppx_rapper/eio.nix { };

  runtime_events_tools = buildDunePackage {
    pname = "runtime_events_tools";
    version = "0.5.0";

    src = builtins.fetchurl {
      url = "https://github.com/tarides/runtime_events_tools/releases/download/0.5.1/runtime_events_tools-0.5.1.tbz";
      sha256 = "0r35cpbmj17ldpfkf4dzk4bs1knfy4hyjz6ax0ayrck25rm397dh";
    };

    propagatedBuildInputs = [ tracing cmdliner hdr_histogram ];
  };

  thread-local-storage = buildDunePackage {
    pname = "thread-local-storage";
    version = "0.1";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/thread-local-storage/releases/download/v0.1/thread-local-storage-0.1.tbz";
      sha256 = "1bk702faacqgwsx96yx9pgkikbxd1nk5xilix3mrg5l9v04gkbbj";
    };
  };

  tls-eio = buildDunePackage {
    pname = "tls-eio";
    inherit (tls) version src;
    propagatedBuildInputs = [ tls mirage-crypto-rng mirage-crypto-rng-eio x509 eio ];
  };

  wayland = osuper.wayland.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/talex5/ocaml-wayland/releases/download/v2.0/wayland-2.0.tbz";
      sha256 = "0jw3x66yscl77w17pp31s4vhsba2xk6z2yvb30fvh0vd9p7ba8c8";
    };
    propagatedBuildInputs = [ eio ];
    checkInputs = o.checkInputs ++ [ eio_main ];
  });

  httpun-ws-eio = callPackage ./httpun-ws/eio.nix { };
}
