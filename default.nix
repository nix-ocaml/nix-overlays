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

    opaline = super.opaline.override {
      ocamlPackages = oP_409.ocamlPackages_4_09;
    };

    ocamlPackages = oP_409.ocamlPackages_4_09;

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
  }
