# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv fetchFromGitHub callPackage;

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      super.ocaml-ng."ocamlPackages_${version}".overrideScope'
        (callPackage ./ocaml { });
  };
  ocamlVersions = [ "4_06" "4_08" "4_09" "4_10" "4_11" "4_12" "4_13" ];
  oPs =
    lib.fold lib.mergeAttrs { }
      (builtins.map overlayOcamlPackages ocamlVersions);

in
{
  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl
  libpq = super.postgresql.override { enableSystemd = false; gssSupport = false; };

  ocamlPackages = oPs.ocamlPackages_4_12;
  ocamlPackages_latest = self.ocamlPackages;
  opaline = (super.opaline.override {
    inherit (self) ocamlPackages;
  });

  ocaml-ng = super.ocaml-ng // oPs // {
    ocamlPackages = self.ocamlPackages;
    ocamlPackages_multicore = (oPs.ocamlPackages_4_12.overrideScope' (oself: osuper: {
      ocaml = osuper.ocaml.overrideAttrs (_: {
        version = "4.12.0+multicore+effects";
        # hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml-multicore/ocaml-multicore/archive/9468d8c91feac55c9b390e50c25b739de043e5e0.tar.gz;
          sha256 = "0zymc0rm5kmydr97jdjbj0wdvlb0ldw57f2i7d915vf8xd0xz9ba";
        };
      });
    })).overrideScope' (callPackage ./ocaml { });
  };

  pkgsCross = super.pkgsCross // {
    musl64 = super.pkgsCross.musl64.appendOverlays (callPackage ./static {
      pkgsNative = self;
      inherit ocamlVersions;
    });

    aarch64-multiplatform = super.pkgsCross.aarch64-multiplatform.appendOverlays (callPackage ./cross {
      inherit ocamlVersions;
      buildPackages = self;
    });

    aarch64-multiplatform-musl =
      (super.pkgsCross.aarch64-multiplatform-musl.appendOverlays
        ((callPackage ./cross { inherit ocamlVersions; }) ++
          (callPackage ./static {
            pkgsNative = self;
            inherit ocamlVersions;
          })));
  };


  # Other packages

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
  });

  inherit (callPackage ./cockroachdb { }) cockroachdb-21_x;
  cockroachdb = self.cockroachdb-21_x;
}
