# An important note about these overlays: `pkgsStatic` propagates all build
# inputs. See: https://github.com/NixOS/nixpkgs/issues/83667

(self: super:
  let
    inherit (super) lib config;
    removeUnknownConfigureFlags = f: with lib;
      remove "--disable-shared"
        (remove "--enable-static" f);

    removeUnknownFlagsAdapter = o: o.overrideAttrs (o: {
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
    });

    addDisableShared = o: o.overrideAttrs (o: {
      configureFlags = o.configureFlags ++ [ "--disable-shared" ];
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

    zlib = removeUnknownFlagsAdapter (super.zlib.override {
      static = true;
      splitStaticOutput = false;
    });

    openssl = (super.openssl.override { static = true; }).overrideAttrs (o: {
      configureFlags = lib.remove "no-shared" o.configureFlags;
    });
  })
