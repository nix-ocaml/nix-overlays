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
    fetchpatch
    buildGoModule
    haskell
    haskellPackages;

  overlayOCamlPackages = attrs: import ../ocaml/overlay-ocaml-packages.nix (attrs // {
    inherit nixpkgs;
  });
  staticLightExtend = pkgSet: pkgSet.extend (self: super:
    super.lib.overlayOCamlPackages {
      inherit self super;
      overlays = [ (super.callPackage ../static/ocaml.nix { }) ];
      updateOCamlPackages = true;
    });

in

(overlayOCamlPackages {
  inherit self super;
  overlays = [
    (callPackage ../ocaml {
      inherit nixpkgs;
      super-opaline = super.opaline;
      oniguruma-lib = super.oniguruma;
      libgsl = super.gsl;
    })
  ];
}) // {
  # Place a canary
  __nix-ocaml-overlays-applied = 1;

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

      riscv64 = super.pkgsCross.riscv64.extend cross-overlay;
    };

  # Override `pkgs.nix` to the unstable channel
  nix = super.nixVersions.latest;

  # Other packages

  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl.
  libpq = (super.postgresql_17.override {
    # a new change does some shenanigans to get llvmStdenv + lld which breaks
    # our cross-compilation
    overrideCC = _: _: super.stdenv;
    systemdSupport = false;
    gssSupport = false;
    openssl = self.openssl-oc;
    jitSupport = false;
    pamSupport = false;
    perlSupport = false;
    pythonSupport = false;
    tclSupport = false;
    lz4 = self.lz4-oc;
    zstd = self.zstd-oc;
    zlib = self.zlib-oc;
  }).overrideAttrs (finalAttrs: o:
    let
      pg_config = super.writeShellScriptBin "pg_config" (builtins.readFile "${nixpkgs}/pkgs/servers/sql/postgresql/pg_config.sh");
    in
    {
      env = {
        CFLAGS = "-fdata-sections -ffunction-sections"
        + (if stdenv.cc.isClang then " -flto" else " -fmerge-constants -Wl,--gc-sections");
        NIX_CFLAGS_COMPILE = "-UUSE_PRIVATE_ENCODING_FUNCS";
      };
      doCheck = false;
      doInstallCheck = false;

      postPatch =
        o.postPatch + lib.optionalString (o.dontDisableStatic or false) ''
          substituteInPlace src/interfaces/libpq/Makefile \
          --replace-fail "echo 'libpq must not be calling any function which invokes exit'; exit 1;" "echo;"
        '';

      configureFlags = [
        "--without-ldap"
        "--without-readline"
        "--with-openssl"
        "--with-libxml"
        "--sysconfdir=/etc"
        "--with-system-tzdata=${super.tzdata}/share/zoneinfo"
        "--enable-debug"
        "--with-icu"
        "--with-lz4"
        "--with-zstd"
        "--with-uuid=e2fs"
      ]
      ++ lib.optionals stdenv.hostPlatform.isRiscV [ "--disable-spinlocks" ]
      ++ lib.optionals stdenv.isLinux [ "--with-pam" ]
      # This could be removed once the upstream issue is resolved:
      # https://postgr.es/m/flat/427c7c25-e8e1-4fc5-a1fb-01ceff185e5b%40technowledgy.de
      ++ lib.optionals stdenv.isDarwin [ "LDFLAGS_EX_BE=-Wl,-export_dynamic" ];

      propagatedBuildInputs = with self; [
        lz4-oc
        zstd-oc
        zlib-oc
        libuuid
        libxml2
        icu
        openssl-oc.dev
      ]
      ++ lib.optionals stdenv.isLinux [ linux-pam ];
      # Use a single output derivation. The upstream PostgreSQL derivation
      # produces multiple outputs (including "out" and "lib"), and then puts some
      # lib/ artifacts in `$lib/lib` and some in `$out/lib`. This causes the
      # pkg-config `--libs` flags to be invalid (since it only knows about one
      # such lib path, not both)
      outputs = [ "out" "dev" "doc" "man" ];

      postInstall = ''
        moveToOutput "bin/ecpg" "$dev"
        moveToOutput "lib/pgxs" "$dev"
        # Pretend pg_config is located in $out/bin to return correct paths, but
        # actually have it in -dev to avoid pulling in all other outputs. See the
        # pg_config.sh script's comments for details.
        moveToOutput "bin/pg_config" "$dev"
        install -c -m 755 "${pg_config}"/bin/pg_config "$out/bin/pg_config"
        wrapProgram "$dev/bin/pg_config" --argv0 "$out/bin/pg_config"
        # postgres exposes external symbols get_pkginclude_path and similar. Those
        # can't be stripped away by --gc-sections/LTO, because they could theoretically
        # be used by dynamically loaded modules / extensions. To avoid circular dependencies,
        # references to -dev, -doc and -man are removed here. References to -lib must be kept,
        # because there is a realistic use-case for extensions to locate the /lib directory to
        # load other shared modules.
        remove-references-to -t "$dev" -t "$doc" -t "$man" "$out/bin/postgres"
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
        # The remaining static libraries are libpgcommon.a, libpgport.a and related.
        # Those are only used when building e.g. extensions, so go to $dev.
        moveToOutput "lib/*.a" "$dev"
      '' +
      lib.optionalString stdenv.hostPlatform.isDarwin ''
        # The darwin specific Makefile for PGXS contains a reference to the postgres
        # binary. Some extensions (here: postgis), which are able to set bindir correctly
        # to their own output for installation, will then fail to find "postgres" during linking.
        substituteInPlace "$dev/lib/pgxs/src/Makefile.port" \
          --replace-fail '-bundle_loader $(bindir)/postgres' "-bundle_loader $out/bin/postgres"
      '';
    });

  gnome2 = super.gnome2 // {
    gtksourceview = super.gtksourceview.overrideAttrs (_: {
      env = lib.optionalAttrs stdenv.cc.isGNU {
        NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
      };
    });
  };

  opaline = null;
  ott = super.ott.override { opaline = self.ocamlPackages.opaline; };

  h2spec = super.buildGoModule {
    pname = "h2spec";
    version = "dev";

    src = fetchFromGitHub {
      owner = "summerwind";
      repo = "h2spec";
      rev = "af83a65f0b";
      sha256 = "sha256-z06uQiImMD4nPLp4Qxka9JT9NTmY0AurnHQKhB/kM40=";
    };
    vendorHash = "sha256-YSaLOYIHgMCK2hXSDL+aoBEfOX7j6rnJ4DMWg0jhzWY=";
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

  dune-dev = self.ocamlPackages.dune_3.overrideAttrs (_: {
    src = super.fetchFromGitHub {
      owner = "ocaml";
      repo = "dune";
      rev = "d6f1a2740ac584127105773a43283829ae7a39e7";
      hash = "sha256-tIa6mIQvhPi6B2c7aK+tq3WJkuEPiDuvRtvHkaxCC3w=";
    };
    configureFlags = [
      "--toolchains enable"
      "--pkg-build-progress enable"
      "--lock-dev-tool enable"
    ];
  });
  opam = self.ocamlPackages.opam;

  pnpm =
    let
      inherit (self)
        writeScriptBin runtimeShell nodejs_latest nodePackages_latest;
    in
    writeScriptBin "pnpm" ''
      #!${runtimeShell}
      ${nodejs_latest}/bin/node \
        ${nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
        "$@"
    '';

  melange-relay-compiler =
    let
      inherit (super) rustPlatform pkg-config openssl;
      melange-relay-compiler-src = stdenv.mkDerivation {
        name = "melange-relay-compiler-src";
        src = fetchFromGitHub {
          owner = "anmonteiro";
          repo = "relay";
          rev = "670aae168499bc1fe8a876bdeb9f60f25f89160c";
          hash = "sha256-Eq804+sWG39WIdmAJIiUrUuop38fKAI8C45pqfEV01k=";
          sparseCheckout = [ "compiler" ];
        };
        dontBuild = true;
        installPhase = ''
          mkdir $out
          cp -r ./* $out
        '';
      };
    in
    rustPlatform.buildRustPackage {
      pname = "relay";
      version = "n/a";
      src = "${melange-relay-compiler-src}/compiler";
      cargoHash = "sha256-3Y7ufcT0c4Tr5J6LlqSDPCj8WUyWg8hned5SSoq1hj4=";

      nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
      # Needed to get openssl-sys to use pkg-config.
      # Doesn't seem to like OpenSSL 3
      OPENSSL_NO_VENDOR = 1;

      buildInputs = lib.optionals stdenv.isLinux [ openssl ];

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
      inherit (super) gmp libev lz4 pcre rdkafka sqlite zlib zstd readline;
      libffi = super.libffi.overrideAttrs (_: { doCheck = false; });
      openssl = super.openssl;
      curl = super.curl.override { openssl = self.openssl-oc; };
    }
)
