(self: super:
  let
    inherit (super) lib config fetchpatch;
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
        mkDerivationFromStdenv = extendMkDerivationArgs old (args: {
          dontDisableStatic = true;
        } // lib.optionalAttrs (!(args.dontAddStaticConfigureFlags or false)) {
          configureFlags = (args.configureFlags or [ ]) ++ [ "--enable-static" ];
          mesonFlags = (args.mesonFlags or [ ]) ++ [ "-Ddefault_library=static" ];
        });
      });

  in
  {
    stdenv = lib.foldl (lib.flip lib.id) super.stdenv [ makeStaticLibraries ];

    alsa-lib = super.alsa-lib.overrideAttrs (o: {
      patches = o.patches ++ [
        (fetchpatch {
          url = https://github.com/alsa-project/alsa-lib/commit/81e7923fbfad45b2f353a4d6e3053af51f5f7d0b.patch;
          sha256 = "1nqm10jkvkfy5p2sx79i22ikj2q8b9mn0whcs8blgjmpy1pv7kb2";
        })
      ];
    });

    zlib = removeUnknownFlagsAdapter (super.zlib.override {
      static = true;
      splitStaticOutput = false;
    });

    openssl = (super.openssl.override { static = true; }).overrideAttrs (o: {
      configureFlags = lib.remove "no-shared" o.configureFlags;
    });

    curl = super.curl.override {
      gssSupport = false;
      brotliSupport = false;
    };

    libkrb5 = super.libkrb5.override { staticOnly = true; };
  })
