# An important note about these overlays: `pkgsStatic` propagates all build
# inputs. See: https://github.com/NixOS/nixpkgs/issues/83667

(self: super:
  let
    inherit (super) lib;
    removeUnknownConfigureFlags = f: with lib;
      # TODO(anmonteiro): probably don't need to remove `"--disable-shared"`,
      # the middleware below already does it.
      remove "--disable-shared"
        (remove "--enable-static" f);

    removeUnknownFlagsAdapter = o: o.overrideAttrs (o: {
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
    });

    inherit (super.stdenvAdapters) makeStaticBinaries propagateBuildInputs;

    inherit (lib) foldl optional flip id composeExtensions optionalAttrs optionalString;
    makeStaticLibraries = stdenv: stdenv //
      {
        mkDerivation = args: stdenv.mkDerivation (args // {
          dontDisableStatic = true;
          configureFlags = (args.configureFlags or [ ]) ++ [
            "--enable-static"
            "--disable-shared"
          ];
          cmakeFlags =
            let flags = (args.cmakeFlags or [ ]); in
            (if flags == null then [ ] else flags) ++ [ "-DBUILD_SHARED_LIBS:BOOL=OFF" ];
          mesonFlags =
            let flags = (args.mesonFlags or [ ]); in
            (if flags == null then [ ] else flags) ++ [ "-Ddefault_library=static" ];
        });
      };


    disablePieHardening = stdenv: stdenv //
      {
        mkDerivation = args: stdenv.mkDerivation (args // {
          hardeningDisable = [ "pie" ];
          configureFlags = super.lib.remove "--disable-shared" (args.configureFlags or [ ]);
        });
      };
    staticAdapters = [
      # this one comes first to remove `--disable-shared` added by `makeStaticLibraries`
      disablePieHardening
      makeStaticLibraries
      # propagateBuildInputs
    ];
    # ++ optional (!super.stdenv.hostPlatform.isDarwin) makeStaticBinaries;
  in
  {
    stdenv = foldl (flip id) super.stdenv staticAdapters;

    zlib = (super.zlib.override {
      static = true;
      # shared = false;
      splitStaticOutput = false;
    }).overrideAttrs (o: {
      configureFlags = (removeUnknownConfigureFlags o.configureFlags);
    });
    openssl = (super.openssl_1_1.override { static = true; }).overrideAttrs (o: {
      # OpenSSL doesn't like the `--enable-static` / `--disable-shared` flags.
      configureFlags = (removeUnknownConfigureFlags o.configureFlags);
    });
    boost = super.boost.override {
      # Don’t use new stdenv for boost because it doesn’t like the
      # --disable-shared flag
      stdenv = super.stdenv;
    };
    perl = super.perl.override {
      # Don’t use new stdenv zlib because
      # it doesn’t like the --disable-shared flag
      stdenv = super.stdenv;
    };

    db48 = super.db48.overrideAttrs (o: {
      hardeningDisable = (o.hardeningDisable or [ ]) ++ [ "format" ];
    });

    clasp = super.clasp.overrideAttrs (o: {
      configurePlatforms = [ ];
      configureFlags = ((removeUnknownConfigureFlags o.configureFlags) ++ [ "--static" ]);

      preBuild = "cd build/release_static";
    });

    kmod = removeUnknownFlagsAdapter (super.kmod.override { withStatic = true; });
  })
