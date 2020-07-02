# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv pkgs;
  gitignoreNix = pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "00b237fb1813c48e20ee2021deb6f3f03843e9e4";
    sha256 = "186pvp1y5fid8mm8c7ycjzwzhv7i6s3hh33rbi05ggrs7r3as3yy";
  };
  gitignoreSource = import gitignoreNix { inherit lib; };

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" = super.ocaml-ng."ocamlPackages_${version}".overrideScope' (pkgs.callPackage ./ocaml {});
  };
  oP_406 = overlayOcamlPackages "4_06";
  oP_409 = overlayOcamlPackages "4_09";
  oP_410 = overlayOcamlPackages "4_10";
  oP_411 = overlayOcamlPackages "4_11";
in
  {
    opaline = super.opaline.override {
      inherit (self) ocamlPackages;
    };

    ocamlPackages = oP_410.ocamlPackages_4_10;
    ocamlPackages_latest = self.ocamlPackages;

    # 4.06, 4.09 and 4.10 treated specially out of convenience because:
    # - 4.09 is still used in some of my projects
    # - 4.10 is the latest stable version
    # - 4.06 is used by BuckleScript
    ocaml-ng = super.ocaml-ng // oP_406 // oP_409 // oP_410 // oP_411;

    # BuckleScript
    bs-platform = pkgs.callPackage ./bs-platform {
      reason = oP_406.ocamlPackages_4_06.reason;
    };

    pkgsCross.musl64.pkgsStatic =
      let mkOverlay = ocamlVersion: import ./static/overlays.nix {
        inherit lib ocamlVersion;
        pkgsNative = pkgs;
      };
      in
      super.pkgsCross.musl64.pkgsStatic.appendOverlays
        (lib.concatMap mkOverlay [ "4_08" "4_09" "4_10" "4_11" ]);

    # Other packages

    lib = super.lib // {
      gitignoreSource = gitignoreSource.gitignoreSource;
    };

    cockroachdb = super.cockroachdb.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = "https://binaries.cockroachdb.com/cockroach-v20.1.3.src.tgz";
        sha256 = "0bg60rcfn2d4awg5al8d5xvk8h7bab986qlbpl9bkv6zpw9wipfb";
      };
    });
  }
