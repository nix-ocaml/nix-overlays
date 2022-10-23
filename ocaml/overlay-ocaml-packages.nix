{ nixpkgs, overlays, super, updateOCamlPackages ? false }:

let
  inherit (super) lib callPackage ocaml-ng;
  ocamlVersions = [
    "4_06"
    "4_08"
    "4_09"
    "4_10"
    "4_11"
    "4_12"
    "4_13"
    "4_14"
    "5_0"
    "trunk"
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
    (if !(ocaml-ng ? "ocamlPackages_trunk") then {
      ocamlPackages_4_14 = ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          hardeningDisable = [ "strictoverflow" ];
        });
      });

      ocamlPackages_5_0 = ocaml-ng.ocamlPackages_5_0.overrideScope' (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = https://github.com/ocaml/ocaml/archive/8bfc42697.tar.gz;
            sha256 = "0b5q8ppmcklvf8dgybcf84h3sn4vr88hirsm6lkrvdp3pvs76sws";
          };
        });
      });

      ocamlPackages_trunk = newOCamlScope {
        major_version = "5";
        minor_version = "1";
        patch_version = "0+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml/ocaml/archive/6a7c70f.tar.gz;
          sha256 = "1fhs1d3hmpj2n8r5r53k15iniph5sc31d35pcq97gjpv4vvsm4la";
        };
        buildPhase = ''
          make -j8 world
          # make bootstrap
          make -j8 world.opt
        '';
      };
    } else { });

  overlaySinglePackageSet = pkgSet:
    builtins.foldl' (acc: x: acc.overrideScope' x) pkgSet overlays;

  overlayOCamlPackages = version:
    lib.nameValuePair
      "ocamlPackages_${version}"
      (overlaySinglePackageSet custom-ocaml-ng."ocamlPackages_${version}");

  oPs = lib.listToAttrs (builtins.map overlayOCamlPackages ocamlVersions);

in

rec {
  ocaml-ng = custom-ocaml-ng // oPs // {
    ocamlPackages = overlaySinglePackageSet custom-ocaml-ng.ocamlPackages;
    ocamlPackages_latest = oPs.ocamlPackages_5_0;
    ocamlPackages_5_00 = lib.warn "`ocamlPackages_5_00` is deprecated: use `ocamlPackages_5_0` instead" oPs.ocamlPackages_5_0;
  };
  ocamlPackages =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackages
    else ocaml-ng.ocamlPackages_4_14;
  ocamlPackages_latest =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackage_latest
    else
      ocaml-ng.ocamlPackages_latest;
  ocaml = ocamlPackages.ocaml;
}
