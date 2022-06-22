{ nixpkgs, overlays, pkgs }:

let
  inherit (pkgs) lib callPackage ocaml-ng;
  ocamlVersions = [
    "4_06"
    "4_08"
    "4_09"
    "4_10"
    "4_11"
    "4_12"
    "4_13"
    "4_14"
    "5_00"
  ];
  newOCamlScope = { major_version, minor_version, patch_version, src, ... }@extraOpts:
    ocaml-ng.ocamlPackages_4_13.overrideScope'
      (oself: osuper: {
        ocaml = (callPackage
          (import "${nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
            inherit major_version minor_version patch_version;
          })
          { }).overrideAttrs (_: { inherit src; } // extraOpts);
      });

  custom-ocaml-ng =
    ocaml-ng //
    (if !(ocaml-ng ? "ocamlPackages_5_00") then {
      ocamlPackages_4_14 = ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          hardeningDisable = [ "strictoverflow" ];
        });
      });

      ocamlPackages_5_00 = newOCamlScope {
        major_version = "5";
        minor_version = "0";
        patch_version = "0+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml/ocaml/archive/29f77d0.tar.gz;
          sha256 = "1rgkq71ncs2lv75vq4im79k32w24ya7jn1r0flma8k3caw87d2qv";
        };
      };

    } else { });

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      builtins.foldl'
        (acc: x: acc.overrideScope' x)
        custom-ocaml-ng."ocamlPackages_${version}"
        overlays;
  };
  oPs =
    lib.fold lib.mergeAttrs { }
      (builtins.map overlayOcamlPackages ocamlVersions);

in
rec {
  ocaml = ocamlPackages.ocaml;
  ocamlPackages = oPs.ocamlPackages_4_13;
  ocamlPackages_latest = ocamlPackages;

  ocaml-ng = custom-ocaml-ng // oPs // {
    inherit ocamlPackages;
  };
}
