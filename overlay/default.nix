# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
final: prev:

let
  inherit (prev)
    lib
    # stdenv
    darwin
    fetchFromGitHub
    callPackage
    fetchpatch
    buildGoModule
    haskell
    haskellPackages;

  stdenv = if super.stdenv.isDarwin then darwin.apple_sdk_11_0.stdenv else super.stdenv;
  super = prev // { inherit stdenv; };

  overlayOCamlPackages = attrs: import ../ocaml/overlay-ocaml-packages.nix (attrs // {
    inherit nixpkgs;
  });
  staticLightExtend = pkgSet: pkgSet.extend (self: super:
    super.lib.overlayOCamlPackages {
      inherit super;
      overlays = [ (super.callPackage ../static/ocaml.nix { }) ];
      updateOCamlPackages = true;
    });

in

(overlayOCamlPackages {
  inherit super;
  overlays = [
    (callPackage ../ocaml {
      inherit nixpkgs;
      super-opaline = super.opaline;
    })
  ];
}) // {
  # Cross-compilation / static overlays
  pkgsMusl = staticLightExtend super.pkgsMusl;
  pkgsStatic = staticLightExtend super.pkgsStatic;

  pkgsCross =
    let
      static-overlay = import ../static;
      cross-overlay = callPackage ../cross { };
    in
    super.pkgsCross // {
      musl64 = super.pkgsCross.musl64.extend static-overlay;

      aarch64-multiplatform =
        super.pkgsCross.aarch64-multiplatform.extend cross-overlay;

      aarch64-multiplatform-musl =
        (super.pkgsCross.aarch64-multiplatform-musl.appendOverlays
          [ cross-overlay static-overlay ]);
    };


  # Other packages

  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl.
  libpq = (super.postgresql_14.override {
    systemd = null;
    libkrb5 = null;
    enableSystemd = false;
    gssSupport = false;
    openssl = final.openssl-oc;
  }).overrideAttrs (o: {
    doCheck = false;
    configureFlags = [
      "--without-ldap"
      "--without-readline"
      "--with-openssl"
      "--with-libxml"
      "--sysconfdir=/etc"
      "--libdir=$(out)/lib"
      "--with-system-tzdata=${super.tzdata}/share/zoneinfo"
      "--enable-debug"
      "--with-icu"
      "--with-lz4"
      (if stdenv.isDarwin then "--with-uuid=e2fs" else "--with-ossp-uuid")
    ] ++ lib.optionals stdenv.hostPlatform.isRiscV [ "--disable-spinlocks" ];

    propagatedBuildInputs = [ final.openssl-oc.dev ];
    # Use a single output derivation. The upstream PostgreSQL derivation
    # produces multiple outputs (including "out" and "lib"), and then puts some
    # lib/ artifacts in `$lib/lib` and some in `$out/lib`. This causes the
    # pkg-config `--libs` flags to be invalid (since it only knows about one
    # such lib path, not both)
    outputs = [ "out" ];
    postInstall = ''
      # Prevent a retained dependency on gcc-wrapper.
      substituteInPlace "$out/lib/pgxs/src/Makefile.global" --replace ${stdenv.cc}/bin/ld ld
      if [ -z "''${dontDisableStatic:-}" ]; then
        # Remove static libraries in case dynamic are available.
        for i in $out/lib/*.a; do
          name="$(basename "$i")"
          ext="${stdenv.hostPlatform.extensions.sharedLibrary}"
          if [ -e "$out/lib/''${name%.a}$ext" ] || [ -e "''${i%.a}$ext" ]; then
            rm "$i"
          fi
        done
      fi
    '';
  });

  binaryen = super.binaryen.overrideAttrs (_: rec {
    version = "108";

    src = fetchFromGitHub {
      owner = "WebAssembly";
      repo = "binaryen";
      rev = "version_${version}";
      sha256 = "sha256-HMPoiuTvYhTDaBUfSOfh/Dt4FdO9jGqUaFpi92pnscI=";
    };

    patches = [
      # https://github.com/WebAssembly/binaryen/pull/4913
      (fetchpatch {
        url = "https://github.com/WebAssembly/binaryen/commit/b70fe755aa4c90727edfd91dc0a9a51febf0239d.patch";
        sha256 = "sha256-kjPLbdiMVQepSJ7J1gK6dRSMI/2SsH39k7W5AMOIrkM=";
      })
    ];
  });

  opaline = null;
  ott = super.ott.override { opaline = final.ocamlPackages.opaline; };
  esy = callPackage ../ocaml/esy { };

  h2spec = final.buildGoModule {
    pname = "h2spec";
    version = "dev";

    src = fetchFromGitHub {
      owner = "summerwind";
      repo = "h2spec";
      rev = "af83a65f0b";
      sha256 = "sha256-z06uQiImMD4nPLp4Qxka9JT9NTmY0AurnHQKhB/kM40=";
    };
    vendorSha256 = "sha256-YSaLOYIHgMCK2hXSDL+aoBEfOX7j6rnJ4DMWg0jhzWY=";
  };

  h3spec = haskell.lib.compose.justStaticExecutables
    (haskellPackages.callPackage
      ({ mkDerivation
       , base
       , bytestring
       , hspec
       , hspec-core
       , http-types
       , http3
       , network
       , quic
       , tls
       , unliftio
       }: mkDerivation rec {
        pname = "h3spec";
        version = "0.1.8";
        src = fetchFromGitHub {
          owner = "kazu-yamamoto";
          repo = "h3spec";
          rev = "b44e487b143a45536206773b06eb2c80cbbae28e";
          sha256 = "sha256-nH4NaxHdnf4kaCCUnJXSkjt5Wkb8qGv3d0+sVjyatXA==";
        };

        isExecutable = true;
        libraryHaskellDepends = [
          base
          bytestring
          hspec
          hspec-core
          http-types
          http3
          network
          quic
          tls
          unliftio
        ];
        executableHaskellDepends = libraryHaskellDepends;
        mainProgram = "h3spec";
        license = lib.licenses.mit;
      })
      { });

  ocamlformat = super.ocamlformat.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace vendor/parse-wyc/menhir-recover/emitter.ml \
      --replace \
      "String.capitalize" "String.capitalize_ascii"
    '';
  });

  lib = lib // { inherit overlayOCamlPackages; };

  inherit (callPackage ../cockroachdb { })
    cockroachdb-21_1_x
    cockroachdb-21_2_x
    cockroachdb-22_x;
  cockroachdb = final.cockroachdb-21_1_x;

  pnpm =
    let
      inherit (prev)
        writeScriptBin runtimeShell nodejs_latest nodePackages_latest;
    in
    writeScriptBin "pnpm" ''
      #!${runtimeShell}
      ${nodejs_latest}/bin/node \
        ${nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
        "$@"
    '';
} // (
  lib.mapAttrs'
    (n: p: lib.nameValuePair "${n}-oc" p)
    {
      inherit (super) zlib gmp libev sqlite pcre;
      libffi = super.libffi.overrideAttrs (_: {
        doCheck = false;
      });
      openssl = super.openssl_3_0;
    }
)
