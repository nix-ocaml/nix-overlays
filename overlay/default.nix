# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv fetchFromGitHub callPackage;
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
  overlays = [ (callPackage ../ocaml { inherit nixpkgs; }) ];
}) // {
  # Cross-compilation / static overlays
  pkgsMusl = staticLightExtend super.pkgsMusl;
  pkgsStatic = staticLightExtend super.pkgsStatic;

  pkgsCross =
    let
      static-overlays = callPackage ../static { inherit (self) pkgsStatic; };
      cross-overlays = callPackage ../cross { };
    in
    super.pkgsCross // {
      musl64 = super.pkgsCross.musl64.appendOverlays static-overlays;

      aarch64-multiplatform =
        super.pkgsCross.aarch64-multiplatform.appendOverlays cross-overlays;

      aarch64-multiplatform-musl =
        (super.pkgsCross.aarch64-multiplatform-musl.appendOverlays
          (cross-overlays ++ static-overlays));
    };


  # Other packages

  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl.
  libpq = (super.postgresql_14.override {
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

  opaline = super.opaline.override { inherit (self) ocamlPackages; };
  esy = callPackage ../ocaml/esy { };

  h2spec = self.buildGoModule {
    pname = "h2spec";
    version = "dev";

    src = builtins.fetchurl {
      url = https://github.com/summerwind/h2spec/archive/af83a65f0b.tar.gz;
      sha256 = "0306n89d5klx13dp870fbxy1righmb7bh3022nb3898k0bs5dx7a";
    };
    vendorSha256 = "sha256-YSaLOYIHgMCK2hXSDL+aoBEfOX7j6rnJ4DMWg0jhzWY=";
  };

  ocamlformat = super.ocamlformat.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace vendor/parse-wyc/menhir-recover/emitter.ml \
      --replace \
      "String.capitalize" "String.capitalize_ascii"
    '';
  });


  lib = lib.fix (self: lib //
  (import
    (builtins.fetchTarball {
      url = https://github.com/hercules-ci/gitignore.nix/archive/5b9e0ff9d3b551234b4f3eb3983744fa354b17f1.tar.gz;
      sha256 = "01l4phiqgw9xgaxr6jr456qmww6kzghqrnbc7aiiww3h6db5vw53";
    })
    { inherit lib; }) // {
    filterSource = { src, dirs ? [ ], files ? [ ] }: (self.cleanSourceWith {
      inherit src;
      # Good examples: https://github.com/NixOS/nixpkgs/blob/master/lib/sources.nix
      filter = name: type:
        let
          path = toString name;
          baseName = baseNameOf path;
          relPath = self.removePrefix (toString src + "/") path;
        in
        self.any (dir: dir == relPath || (self.hasPrefix "${dir}/" relPath)) dirs ||
        (type == "regular" && (self.any (file: file == baseName) files));
    });

    filterGitSource = args: self.gitignoreSource (self.filterSource args);

    inherit overlayOCamlPackages;
  });

  inherit (callPackage ../cockroachdb { })
    cockroachdb-21_1_x
    cockroachdb-21_2_x
    cockroachdb-22_x;
  cockroachdb = self.cockroachdb-21_1_x;

  pnpm = self.writeScriptBin "pnpm" ''
    #!${self.runtimeShell}
    ${self.nodejs_latest}/bin/node \
      ${self.nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
      "$@"
  '';
} // (
  lib.mapAttrs'
    (n: p: lib.nameValuePair "${n}-oc" p)
    {
      inherit (super) zlib gmp;
      libffi = super.libffi.overrideAttrs (_: {
        doCheck = false;
      });
      openssl = super.openssl_3_0;
    }
)
