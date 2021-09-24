# An important note about these overlays: `pkgsStatic` propagates all build
# inputs. See: https://github.com/NixOS/nixpkgs/issues/83667

(self: super:
  let
    inherit (super) lib config;
    removeUnknownConfigureFlags = f: with lib;
      # TODO(anmonteiro): probably don't need to remove `"--disable-shared"`,
      # the middleware below already does it.
      remove "--disable-shared"
        (remove "--enable-static" f);

    removeUnknownFlagsAdapter = o: o.overrideAttrs (o: {
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
    });

    defaultMkDerivationFromStdenv = import "${import ../sources.nix}/pkgs/stdenv/generic/make-derivation.nix" { inherit lib config; };

    withOldMkDerivation = stdenvSuperArgs: k: stdenvSelf:
      let
        mkDerivationFromStdenv-super = stdenvSuperArgs.mkDerivationFromStdenv or defaultMkDerivationFromStdenv;
        mkDerivationSuper = mkDerivationFromStdenv-super stdenvSelf;
      in
      k stdenvSelf mkDerivationSuper;

    extendMkDerivationArgs = old: f: withOldMkDerivation old (_: mkDerivationSuper: args:
      mkDerivationSuper (args // f args));
    makeStaticLibraries = stdenv:
      stdenv.override (old: {
        # hostPlatform = old.hostPlatform // { isStatic = true; };
        mkDerivationFromStdenv = extendMkDerivationArgs old (args: {
          dontDisableStatic = true;
        } // lib.optionalAttrs (!(args.dontAddStaticConfigureFlags or false)) {
          configureFlags = (args.configureFlags or [ ]) ++ [
            "--enable-static"
          ];
          cmakeFlags = (args.cmakeFlags or [ ]) ++ [ "-DBUILD_SHARED_LIBS:BOOL=OFF" ];
          mesonFlags = (args.mesonFlags or [ ]) ++ [ "-Ddefault_library=static" ];
        });
      });

  in
  {
    stdenv = lib.foldl (lib.flip lib.id) super.stdenv [ makeStaticLibraries ];

    zlib = (super.zlib.override {
      static = true;
      # shared = false;
      splitStaticOutput = false;
    }).overrideAttrs (o: {
      configureFlags = (removeUnknownConfigureFlags o.configureFlags);
    });

    openssl = (super.openssl_1_1.override { static = true; });

    # db48 = super.db48.overrideAttrs (o: {
    # hardeningDisable = (o.hardeningDisable or [ ]) ++ [ "format" ];
    # });

    # clasp = super.clasp.overrideAttrs (o: {
    # configurePlatforms = [ ];
    # configureFlags = ((removeUnknownConfigureFlags o.configureFlags) ++ [ "--static" ]);

    # preBuild = "cd build/release_static";
    # });

    # kmod = removeUnknownFlagsAdapter (super.kmod.override { withStatic = true; });
  })
