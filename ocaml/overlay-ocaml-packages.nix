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
    "5_1"
    "5_2"
    "trunk"
    "jst"
  ];
  newOCamlScope = { major_version, minor_version, patch_version, src, ... }@extraOpts:
    ocaml-ng.mkOcamlPackages
      ((callPackage
        (import "${nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
          inherit major_version minor_version patch_version;
        })
        { }).overrideAttrs (_: { inherit src; } // extraOpts));

  custom-ocaml-ng =
    ocaml-ng //
    (if !(ocaml-ng ? "ocamlPackages_trunk") then {
      ocamlPackages_4_14 = ocaml-ng.ocamlPackages_4_14.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          hardeningDisable = [ "strictoverflow" ];
        });
      });

      ocamlPackages_5_2 = newOCamlScope {
        major_version = "5";
        minor_version = "2";
        patch_version = "0~beta1";
        hardeningDisable = [ "strictoverflow" ];
        src = super.fetchFromGitHub {
          owner = "ocaml";
          repo = "ocaml";
          rev = "5.2.0-beta1";
          hash = "sha256-VfHjckJImGBlxl0jI2FkBcKd35vyCmjtD17MQNRBLl8=";
        };

        buildPhase = ''
          runHook preBuild
          make world -j -j$NIX_BUILD_CORES

          # Bootstrapping currently causes "dllunixbyt.so" can't be found
          # make bootstrap

          make world.opt -j -j$NIX_BUILD_CORES
          runHook postBuild
        '';
      };

      ocamlPackages_trunk = newOCamlScope {
        major_version = "5";
        minor_version = "3";
        patch_version = "0+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = super.fetchFromGitHub {
          owner = "ocaml";
          repo = "ocaml";
          rev = "7f3ecc86e7d982dbef8fddcf9d744c1eb5d9f014";
          hash = "sha256-DKN3z9qPpZujsxY37d/11R7WzGIqfhNZn1oMsiB/cz8=";
        };
      };

      ocamlPackages_jst = ocaml-ng.ocamlPackages_4_14.overrideScope (oself: osuper: {
        ocaml = (callPackage
          (import "${nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
            major_version = "4";
            minor_version = "14";
            patch_version = "1+jst";
          })
          { }).overrideAttrs (o: {
          src = super.fetchFromGitHub {
            owner = "ocaml-flambda";
            repo = "ocaml-jst";
            rev = "e3076d2e7321a8e8ff18e560ed7a55d6ff0ebf04";
            hash = "sha256-y5p73ZZtwkgUzvCHlE9nqA2OdlDbYWr8wnWRhYH82hE=";
          };
          hardeningDisable = [ "strictoverflow" ];
        });

        dune_3 = osuper.dune_3.overrideAttrs (_: {
          postPatch = ''
            substituteInPlace boot/bootstrap.ml --replace-fail 'v >= (5, 0, 0)' "true"
            substituteInPlace boot/duneboot.ml --replace-fail 'ocaml_version >= (5, 0)' "true"
            substituteInPlace src/ocaml-config/ocaml_config.ml --replace-fail 'version >= (5, 0, 0)' "true"
            substituteInPlace src/ocaml/version.ml --replace-fail 'version >= (5, 0, 0)' "true"
          '';
        });
      });

    } else { });

  overlaySinglePackageSet = pkgSet:
    builtins.foldl' (acc: x: acc.overrideScope x) pkgSet overlays;

  overlayOCamlPackages = version:
    lib.nameValuePair
      "ocamlPackages_${version}"
      (overlaySinglePackageSet custom-ocaml-ng."ocamlPackages_${version}");

  oPs = lib.listToAttrs (builtins.map overlayOCamlPackages ocamlVersions);

in

rec {
  ocaml-ng = custom-ocaml-ng // oPs // {
    ocamlPackages = overlaySinglePackageSet custom-ocaml-ng.ocamlPackages;
    ocamlPackages_latest = oPs.ocamlPackages_5_1;
  };
  ocamlPackages =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackages
    else ocaml-ng.ocamlPackages_5_1;
  ocamlPackages_latest =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackage_latest
    else
      ocaml-ng.ocamlPackages_latest;
  ocaml = ocamlPackages.ocaml;
}
