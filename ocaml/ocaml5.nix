{ darwin
, fetchFromGitHub
, nodejs_latest
, oself
, osuper
, nixpkgs
, stdenv
, overrideSDK
}:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

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

  eio-trace =
    let
      stdenv' =
        if stdenv.isDarwin && !stdenv.isAarch64
        then overrideSDK stdenv "11.0"
        else stdenv;
    in
    buildDunePackage {
      stdenv = stdenv';
      pname = "eio-trace";
      version = "0.4";
      src = builtins.fetchurl {
        url = "https://github.com/ocaml-multicore/eio-trace/releases/download/v0.4/eio-trace-0.4.tbz";
        sha256 = "1bry9v9c0izz5slhq11q7jgzg6myajfsvx3sg9h2zmcj9irr1xg5";
      };
      propagatedBuildInputs = [ eio_main lablgtk3 processor cmdliner ];
    };

  graphql-eio = buildDunePackage {
    pname = "graphql-eio";
    inherit (graphql_parser) src version;
    propagatedBuildInputs = [ eio_main graphql ];
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

  moonpool = buildDunePackage {
    pname = "moonpool";
    version = "0.7";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/moonpool/releases/download/v0.7/moonpool-0.7.tbz";
      sha256 = "058vqpza66z5687n90s18pzn1cnvkwv3mphlc1zsnc0541sgk8f4";
    };

    propagatedBuildInputs = [ either picos_std ];
    doCheck = false;
    nativeCheckInputs = [ mdx ];
    checkInputs = [ mdx qcheck-core trace trace-tef ];
  };

  multicore-magic-dscheck = buildDunePackage {
    pname = "multicore-magic-dscheck";
    inherit (multicore-magic) src version;
    propagatedBuildInputs = [ dscheck ];
  };

  carl = callPackage ./piaf/carl.nix { };

  picos = buildDunePackage {
    pname = "picos";
    version = "0.6.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/picos/releases/download/0.6.0/picos-0.6.0.tbz";
      sha256 = "1ykx11c8jnjf24anwdzmmf7dmwbqf63z6s3x5yp2sp7nkhchhniz";
    };
    propagatedBuildInputs = [ backoff thread-local-storage ];
  };

  picos_aux = buildDunePackage {
    pname = "picos_aux";
    inherit (picos) src version;
    propagatedBuildInputs = [ backoff multicore-magic ];
  };

  picos_std = buildDunePackage {
    pname = "picos_std";
    inherit (picos) src version;
    propagatedBuildInputs = [ picos picos_aux backoff multicore-magic ];
  };

  picos_io = buildDunePackage {
    pname = "picos_io";
    inherit (picos) src version;
    propagatedBuildInputs = [
      picos_aux
      picos_std
      backoff
      mtime
      multicore-magic
      psq
    ];
  };

  picos_lwt = buildDunePackage {
    pname = "picos_lwt";
    inherit (picos) src version;
    propagatedBuildInputs = [ picos_aux picos_std lwt ];
  };

  picos_mux = buildDunePackage {
    pname = "picos_mux";
    inherit (picos) src version;
    propagatedBuildInputs = [ picos_aux picos_std multicore-magic backoff ];
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

  tar-eio = buildDunePackage {
    pname = "tar-eio";
    inherit (tar) version src;
    propagatedBuildInputs = [ tar eio ];
  };

  thread-local-storage = buildDunePackage {
    pname = "thread-local-storage";
    version = "0.2";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/thread-local-storage/releases/download/v0.2/thread-local-storage-0.2.tbz";
      sha256 = "0j83gv6iwx6w1iq6jf5pvbzh7lf45riiw53nzhzrk7vzs0g2p3m6";
    };
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
