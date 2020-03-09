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
  oP_410 = overlayOcamlPackages "4_10";
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

    ocamlPackages = oP_410.ocamlPackages_4_10;
    ocamlPackages_latest = self.ocamlPackages;

    # 4.06, 4.09 and 4.10 treated specially out of convenience because:
    # - 4.09 is still used in some of my projects
    # - 4.10 is the latest stable version
    # - 4.06 is used by BuckleScript
    ocaml-ng = super.ocaml-ng // oP_406 // oP_409 // oP_410;

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
        (lib.concatMap mkOverlay [ "4_08" "4_09" "4_10" ]);

    # Other packages

    lib = super.lib // {
      gitignoreSource = (import (pkgs.fetchFromGitHub {
        owner = "hercules-ci";
        repo = "gitignore.nix";
        rev = "2ced4519f865341adcb143c5d668f955a2cb997f";
        sha256 = "0fc5bgv9syfcblp23y05kkfnpgh3gssz6vn24frs8dzw39algk2z";
      }) { inherit lib; }).gitignoreSource;
    };
  }
