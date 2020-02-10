# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv pkgs;
  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" = super.ocaml-ng."ocamlPackages_${version}".overrideScope' (pkgs.callPackage ./ocaml {});
  };
  oP_406 = overlayOcamlPackages "4_06";
  oP_409 = overlayOcamlPackages "4_09";
in
  {
    # OCaml related packages
    ocamlformat = super.ocamlformat.overrideAttrs (o: {
      src = builtins.fetchurl {
        url = "https://github.com/ocaml-ppx/ocamlformat/releases/download/0.13.0/ocamlformat-0.13.0-2.tbz";
        sha256 = "0ki2flqi3xkhw9mfridivb6laxm7gml8rj9qz42vqmy9yx76jjxq";
      };
    });

    opaline = super.opaline.override {
      inherit (self) ocamlPackages;
    };

    ocamlPackages = oP_409.ocamlPackages_4_09;
    ocamlPackages_latest = self.ocamlPackages;

    # 4.06 and 4.09 treated specially out of convenience because:
    # - 4.09 is the latest stable version
    # - 4.06 is used by BuckleScript
    ocaml-ng = super.ocaml-ng // oP_409 // oP_406;

    # BuckleScript
    bs-platform = pkgs.callPackage ./bs-platform {
      reason = oP_406.ocamlPackages_4_06.reason;
    };

    pkgsCross.musl64.pkgsStatic = super.pkgsCross.musl64.pkgsStatic.appendOverlays (import ./static/overlays.nix {
      inherit lib;
      pkgsNative = pkgs;
      ocamlVersion = "4_09";
    });

    # Other packages

    lib = super.lib // {
      gitignoreSource = (import (pkgs.fetchFromGitHub {
        owner = "hercules-ci";
        repo = "gitignore";
        rev = "7415c4f";
        sha256 = "1zd1ylgkndbb5szji32ivfhwh04mr1sbgrnvbrqpmfb67g2g3r9i";
      }) { inherit lib; }).gitignoreSource;
    };
  }
