# An important note about these overlays: `pkgsStatic` propagates all build
# inputs. See: https://github.com/NixOS/nixpkgs/issues/83667

  (self: super:
    let
      removeUnknownConfigureFlags = f: with super.lib;
        remove "--disable-shared"
        (remove "--enable-static" f);
      dds = x: x.overrideAttrs (o: { dontDisableStatic = true; });
      inherit (super.stdenvAdapters) makeStaticLibraries;
      inherit (super.lib) foldl optional flip id composeExtensions optionalAttrs optionalString;
      disablePieHardening = stdenv: stdenv //
        { mkDerivation = args: stdenv.mkDerivation (args // {
            hardeningDisable = ["pie"];
          });
        };
      staticAdapters = [
        makeStaticLibraries
        disablePieHardening
      ];
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

      libpq = dds super.libpq;
    })
