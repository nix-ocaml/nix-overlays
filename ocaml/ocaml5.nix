{
  lib,
  fetchFromGitHub,
  oself,
  osuper,
  makeWrapper,
  nix-eval-jobs,
}:

with oself;

{
  archi-eio = callPackage ./archi/eio.nix { };

  caqti-eio = buildDunePackage {
    inherit (caqti) version src;
    pname = "caqti-eio";
    propagatedBuildInputs = [
      eio
      eio_main
      caqti
    ];
  };

  cohttp-eio = buildDunePackage {
    pname = "cohttp-eio";
    inherit (http) src version;
    doCheck = false;
    propagatedBuildInputs = [
      cohttp
      eio_main
      ptime
    ];
  };

  eio =
    if lib.versionAtLeast ocaml.version "5.2" then
      osuper.eio.overrideAttrs (o: {
        version = "1.4";
        src = builtins.fetchurl {
          url = "https://github.com/ocaml-multicore/eio/releases/download/v1.4/eio-1.4.tbz";
          sha256 = "19da8r1lx8z9hvgnv00n03ql6mlhqjyv7wl6nkdk08a9dx4as4ds";
        };
        buildInputs = (o.buildInputs or [ ]) ++ [ dune-configurator ];
      })
    else
      osuper.eio;

  eio_linux =
    if lib.versionAtLeast ocaml.version "5.2" then
      osuper.eio_linux.overrideAttrs (o: {
        buildInputs = (o.buildInputs or [ ]) ++ [ dune-configurator ];
      })
    else
      # Eio 0.12 supports OCaml 5.0, and Eio 1.2 supports OCaml 5.1.
      buildDunePackage {
        pname = "eio_linux";
        inherit (eio)
          meta
          patches
          src
          version
          ;
        minimalOCamlVersion = "5.0";
        dontStrip = true;
        propagatedBuildInputs = [
          eio
          fmt
          logs
          uring
        ];
      };

  eio_windows = buildDunePackage {
    pname = "eio_windows";
    inherit (eio) src version;
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [
      eio
      fmt
    ];
  };

  eio-trace = buildDunePackage {
    pname = "eio-trace";
    version = "0.4";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/eio-trace/releases/download/v0.4/eio-trace-0.4.tbz";
      sha256 = "1bry9v9c0izz5slhq11q7jgzg6myajfsvx3sg9h2zmcj9irr1xg5";
    };
    propagatedBuildInputs = [
      eio_main
      lablgtk3
      processor
      cmdliner
    ];
  };

  graphql-eio = buildDunePackage {
    pname = "graphql-eio";
    inherit (graphql_parser) src version;
    propagatedBuildInputs = [
      eio_main
      graphql
    ];
  };

  kafka-eio = buildDunePackage {
    pname = "kafka-eio";
    inherit (kafka) hardeningDisable version src;
    propagatedBuildInputs = [
      eio
      kafka
    ];
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

    propagatedBuildInputs = [
      either
      picos_std
    ];
    doCheck = false;
    nativeCheckInputs = [ mdx ];
    checkInputs = [
      mdx
      qcheck-core
      trace
      trace-tef
    ];
  };

  carl = callPackage ./piaf/carl.nix { };

  nix-ci-build = buildDunePackage {
    pname = "nix-ci-build";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "nix-ocaml";
      repo = "nix-ci-build";
      rev = "328a9485d3da222a92ddd26a865e06a8c30305df";
      hash = "sha256-fHTnFRXW18dTNh5yTSwgVj031XbKv8ZvzA4nn7vi8cs=";
    };

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ nix-eval-jobs ];
    propagatedBuildInputs = [
      cmdliner
      eio_main
      logs
      fmt
      ppx_yojson_conv
    ];
    postInstall =
      let
        path = lib.makeBinPath [ nix-eval-jobs ];
      in
      ''
        wrapProgram "$out/bin/nix-ci-build" --prefix PATH : ${path}
      '';
  };

  picos = buildDunePackage {
    pname = "picos";
    version = "0.6.0";
    src = fetchFromGitHub {
      owner = "ocaml-multicore";
      repo = "picos";
      rev = "5d7e5581462babc241d577eddc84aeceecbb2073";
      hash = "sha256-1t8wGgAfv4MpZSQSza2y5EUPvKAkcADuYdEE5NeUr9w=";
    };

    propagatedBuildInputs = [
      backoff
      thread-local-storage
    ];
  };

  picos_aux = buildDunePackage {
    pname = "picos_aux";
    inherit (picos) src version;
    propagatedBuildInputs = [
      backoff
      multicore-magic
    ];
  };

  picos_std = buildDunePackage {
    pname = "picos_std";
    inherit (picos) src version;
    propagatedBuildInputs = [
      picos
      picos_aux
      backoff
      multicore-magic
    ];
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
    propagatedBuildInputs = [
      picos_aux
      picos_std
      lwt
    ];
  };

  picos_mux = buildDunePackage {
    pname = "picos_mux";
    inherit (picos) src version;
    propagatedBuildInputs = [
      picos_aux
      picos_std
      multicore-magic
      backoff
    ];
  };

  ppx_rapper_eio = callPackage ./ppx_rapper/eio.nix { };

  runtime_events_tools = buildDunePackage {
    pname = "runtime_events_tools";
    version = "0.5.4";

    src = fetchFromGitHub {
      owner = "tarides";
      repo = "runtime_events_tools";
      rev = "0.5.4";
      hash = "sha256-sheKhmvPq9g2nvmG15EYNApybCPDH/xanFGgLQ/3fgM=";
    };

    propagatedBuildInputs = [
      tracing
      trace-fuchsia
      cmdliner
      hdr_histogram
    ];
  };

  tar-eio = buildDunePackage {
    pname = "tar-eio";
    inherit (tar) version src;
    propagatedBuildInputs = [
      tar
      eio
    ];
  };

  thread-local-storage = buildDunePackage {
    pname = "thread-local-storage";
    version = "0.2";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/thread-local-storage/releases/download/v0.2/thread-local-storage-0.2.tbz";
      sha256 = "0j83gv6iwx6w1iq6jf5pvbzh7lf45riiw53nzhzrk7vzs0g2p3m6";
    };
  };

  wayland = osuper.wayland.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + lib.optionalString (lib.versionAtLeast ocaml.version "5.6") ''
        substituteInPlace lib/wayland.ml \
          --replace-fail \
            'let callback fn = object
          inherit [_] Wayland_client.Wl_callback.v1
          method on_done ~callback_data = fn callback_data
        end' \
            'let callback fn =
          (object
            inherit [[`V1]] Wayland_client.Wl_callback.v1
            method on_done ~callback_data = fn callback_data
          end :> [`V1] Wayland_client.Wl_callback.v1)'
      '';
  });

  httpun-ws-eio = callPackage ./httpun-ws/eio.nix { };
}
