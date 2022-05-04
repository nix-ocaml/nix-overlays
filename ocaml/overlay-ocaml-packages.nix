{ nixpkgs, extraOverlays }:

self: super:

let
  inherit (super) lib callPackage;
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
    super.ocaml-ng.ocamlPackages_4_13.overrideScope'
      (oself: osuper: {
        ocaml = (callPackage
          (import "${nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
            inherit major_version minor_version patch_version;
          })
          { }).overrideAttrs (_: { inherit src; } // extraOpts);
      });

  custom-ocaml-ng =
    super.ocaml-ng //
    (if !(super.ocaml-ng ? "ocamlPackages_5_00") then {
      ocamlPackages_4_14 = super.ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          hardeningDisable = [ "strictoverflow" ];
        });
      });

      ocamlPackages_5_00 = newOCamlScope {
        major_version = "5";
        minor_version = "00";
        patch_version = "0+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml/ocaml/archive/7585460b818662d9f753f849249b3f571a86b58d.tar.gz;
          sha256 = "0nw8sph3bmn11aihxq3icnfkpvwg3mhhkm1x0y1kpimi6570qx7x";
        };
      };

    } else { });

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      builtins.foldl'
        (acc: x: acc.overrideScope' x)
        custom-ocaml-ng."ocamlPackages_${version}"
        extraOverlays;
  };
  oPs =
    lib.fold lib.mergeAttrs { }
      (builtins.map overlayOcamlPackages ocamlVersions);

in
{
  ocaml = self.ocamlPackages.ocaml;
  ocamlPackages = oPs.ocamlPackages_4_13;
  ocamlPackages_latest = self.ocamlPackages;

  ocaml-ng = custom-ocaml-ng // oPs // {
    ocamlPackages = self.ocamlPackages;
  };
}
