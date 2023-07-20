# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super)
    lib
    stdenv
    fetchFromGitHub
    callPackage
    darwin
    fetchpatch
    fetchgit
    buildGoModule
    haskell
    haskellPackages
    fontconfig;

  overlayOCamlPackages = attrs: import ../ocaml/overlay-ocaml-packages.nix (attrs // {
    inherit nixpkgs;
  });
  staticLightExtend = pkgSet: pkgSet.extend (self: super:
    super.lib.overlayOCamlPackages {
      inherit super;
      overlays = [
        (super.callPackage ../static/ocaml.nix { })
      ];
      updateOCamlPackages = true;
    });

in

(overlayOCamlPackages {
  inherit super;
  overlays = [
    (callPackage ../ocaml {
      inherit nixpkgs;
      super-opaline = super.opaline;
      libfontconfig = fontconfig;
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
  libpq = (super.postgresql_15.override {
    systemd = null;
    libkrb5 = null;
    enableSystemd = false;
    gssSupport = false;
    openssl = self.openssl-oc;
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

    patches = [
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/disable-resolve_symlinks.patch"
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/less-is-more.patch"
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/hardcode-pgxs-path.patch"
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/specify_pkglibdir_at_runtime.patch"
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/findstring.patch"
      (super.substituteAll {
        src = "${nixpkgs}/pkgs/servers/sql/postgresql/locale-binary-path.patch";
        locale = "${if stdenv.isDarwin then super.darwin.adv_cmds else lib.getBin stdenv.cc.libc}/bin/locale";
      })
    ] ++ lib.optionals stdenv.isLinux [
      "${nixpkgs}/pkgs/servers/sql/postgresql/patches/socketdir-in-run-13.patch"
    ];

    propagatedBuildInputs = [ self.openssl-oc.dev ];
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
  ott = super.ott.override { opaline = self.ocamlPackages.opaline; };
  esy = callPackage ../ocaml/esy { };
  esy-skia = stdenv.mkDerivation rec {
    name = "skia";
    src = fetchFromGitHub {
      owner = "revery-ui";
      repo = "esy-skia";
      rev = "29349b9279ed24a73ec41acd7082caea9bd8c04e";
      sha256 = "sha256-VyY1clAdTEZu0cFy/+Bw19OQ4lb55s4gIV/7TsFKdnk=";
    };
    nativeBuildInputs = with self; ([
      gn
      ninja
      libjpeg
      libpng
      zlib
      python3
      expat
      # TODO: add optional webp support
      #libwebp
      # TODO handle ios, android
      #-framework CoreServices -framework CoreGraphics -framework CoreText -framework CoreFoundation
    ] ++
    lib.optionals stdenv.isDarwin [
      darwin.cctools
      darwin.apple_sdk.frameworks.ApplicationServices
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.OpenGL
      # TODO handle ios, android
      #-framework CoreServices -framework CoreGraphics -framework CoreText -framework CoreFoundation
    ] ++
    lib.optionals (stdenv.isDarwin && !stdenv.isAarch64) [ darwin.cctools ]
    );
    patches = lib.optionals (stdenv.isDarwin && !stdenv.isAarch64) [
      ../ocaml/revery/patches/0002-esy-skia-use-libtool.patch
    ];
    preConfigure =
      let
        angle2 = fetchgit
          {
            url = "https://chromium.googlesource.com/angle/angle.git";
            rev = "47b3db22be33213eea4ad58f2453ee1088324ceb";
            sha256 = "sha256-ZF5wDOqh3cRfQGwOMay//4aWh9dBWk/cLmUsx+Ab2vw=";
          };
        piex = fetchgit
          {
            url = "https://android.googlesource.com/platform/external/piex.git";
            rev = "bb217acdca1cc0c16b704669dd6f91a1b509c406";
            sha256 = "05ipmag6k55jmidbyvg5mkqm69zfw03gfkqhi9jnjlmlbg31y412";
          };
      in
      ''
         mkdir -p third_party/externals
         ln -s ${angle2} third_party/externals/angle2
         ln -s ${piex} third_party/externals/piex

        substituteInPlace gn/BUILDCONFIG.gn --replace "gn/is_clang.py" "is_clang.py"
        substituteInPlace gn/is_clang.py --replace "print 'true'" "print('true')"
        substituteInPlace gn/is_clang.py --replace "print 'false'" "print('false')"
        substituteInPlace gn/is_clang.py --replace "shell=True)" "shell=True).decode(sys.stdout.encoding)"
      '';
    #TODO: built this based on feature flags, with sane defaults per os
    #TODO: enable more features
    configurePhase = ''
      runHook preConfigure
      gn gen out/Release \
        --args='is_debug=false is_official_build=true skia_use_egl=false skia_use_dng_sdk=false skia_enable_tools=false extra_asmflags=[] host_os="${if stdenv.isDarwin then "mac" else "linux"}" skia_enable_gpu=true skia_use_metal=${lib.trivial.boolToString stdenv.isDarwin} skia_use_vulkan=false skia_use_angle=false skia_use_fontconfig=false skia_use_freetype=false skia_enable_pdf=false skia_use_sfntly=false skia_use_icu=false skia_use_libwebp=false skia_use_libpng=true esy_skia_enable_svg=true target_cpu="${if stdenv.isAarch64 then "arm64" else "x86_64"}"'
      runHook postConfigure
    '';
    buildPhase = ''
      runHook preBuild
      ninja -C out/Release skia
      runHook postBuild
    '';

    # TODO: these includes were taken from alperite and can probably be simplified to include everything
    installPhase = ''
      mkdir -p $out

      # Glob will match all subdirs.
      shopt -s globstar

      cp -r --parents -t $out/ \
        include/codec \
        include/config \
        include/core \
        include/effects \
        include/gpu \
        include/private \
        include/utils \
        include/c \
        out/Release/*.a \
        src/gpu/**/*.h \
        third_party/externals/angle2/include \
        third_party/skcms/**/*.h
    '';
  };

  h2spec = self.buildGoModule
    {
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

  lib = lib // { inherit overlayOCamlPackages; };

  inherit (callPackage ../cockroachdb { })
    cockroachdb-21_1_x
    cockroachdb-21_2_x
    cockroachdb-22_x;
  cockroachdb = self.cockroachdb-21_1_x;

  opam = self.ocamlPackages.opam;

  pnpm =
    let
      inherit (self)
        writeScriptBin
        runtimeShell
        nodejs_latest
        nodePackages_latest;
    in
    writeScriptBin
      "pnpm"
      ''
        #!${runtimeShell}
        ${nodejs_latest}/bin/node \
          ${nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
          "$@"
      '';

  rdkafka = super.rdkafka.overrideAttrs
    (_: {
      src = super.fetchFromGitHub {
        owner = "confluentinc";
        repo = "librdkafka";
        rev = "v2.2.0";
        hash = "sha256-v/FjnDg22ZNQHmrUsPvjaCs4UQ/RPAxQdg9i8k6ba/4=";
      };
    });

  melange-relay-compiler =
    let
      inherit (super)
        rustPlatform
        darwin
        pkg-config
        openssl;
      melange-relay-compiler-src = stdenv.mkDerivation
        {
          name = "melange-relay-compiler-src";
          src = fetchFromGitHub {
            owner = "anmonteiro";
            repo = "relay";
            rev = "59b2edc6a9332ec83b79166bd6b1c9535d4bf6ab";
            hash = "sha256-3uN/oPMJd5bTCrINzGpkApb5fRTKj6TwPE6NCcXf95g=";
            sparseCheckout = [ "compiler" ];
          };
          # patches = [ ./reason-relay-cargo.patch ];
          dontBuild = true;
          installPhase = ''
            mkdir $out
            cp -r ./* $out
          '';
        };
    in
    rustPlatform.buildRustPackage
      {
        pname = "relay";
        version = "n/a";
        src = "${melange-relay-compiler-src}/compiler";
        cargoHash = "sha256-iyFSsvw3+YCiJz43XVE2IhvooimWdNvuLsBKPtC5EWk=";

        nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
        # Needed to get openssl-sys to use pkg-config.
        # Doesn't seem to like OpenSSL 3
        OPENSSL_NO_VENDOR = 1;

        buildInputs = lib.optionals stdenv.isLinux [ openssl ];
        propagatedBuildInputs = lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Security
        ];

        postInstall = ''
          mv $out/bin/relay $out/bin/melange-relay-compiler
          ln -sf $out/bin/melange-relay-compiler $out/bin/melrelay
        '';
        doCheck = false;
        meta = with lib; {
          description = "Melange Relay compiler";
          homepage = "https://github.com/anmonteiro/relay";
          maintainers = [ maintainers.anmonteiro ];
        };
      };
} // (
  lib.mapAttrs'
    (n: p: lib.nameValuePair "${n}-oc" p)
    {
      inherit (super) zlib gmp libev pcre zstd rdkafka sqlite;
      libffi = super.libffi.overrideAttrs (_: { doCheck = false; });
      openssl = super.openssl_3_0;
    }
)
