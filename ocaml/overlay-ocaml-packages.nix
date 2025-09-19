{ nixpkgs, overlays, super, self, updateOCamlPackages ? false }:

let
  inherit (super) lib callPackage ocaml-ng;
  ocamlVersions = [
    "4_12"
    "4_13"
    "4_14"
    "5_0"
    "5_1"
    "5_2"
    "5_3"
    "5_4"
    "trunk"
    "jst"
  ];
  newOCamlScope = { major_version, minor_version, patch_version, src, ... }@extraOpts:
    ocaml-ng.mkOcamlPackages
      ((callPackage
        (import "${nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
          inherit major_version minor_version patch_version;
        })
        { }).overrideAttrs (o: {
        inherit src;
      } //
      (if lib.isFunction (extraOpts.overrideAttrs or null)
      then extraOpts.overrideAttrs o
      else extraOpts)));

  custom-ocaml-ng =
    ocaml-ng //
    (if !(ocaml-ng ? "ocamlPackages_trunk") then {
      ocamlPackages_4_12 = ocaml-ng.ocamlPackages_4_12.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "4.12.1";
            hash = "sha256-xIBRHPG0cmhKr0mYp+wKl1a9Bo0PYX2Uc8VO7lCMVzM=";
          };
        });
      });
      ocamlPackages_4_13 = ocaml-ng.ocamlPackages_4_13.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "4.13.1";
            hash = "sha256-Mq4mQ9ZgzSpw21b2s55fPsA7rKqXCESr+TAg6PfzU8Q=";
          };
        });
      });
      ocamlPackages_4_14 = ocaml-ng.ocamlPackages_4_14.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "4.14.2";
            hash = "sha256-xKcFQ8vkiOTw7CAMddF8Xf82GNpg879bUdyVC63XREg=";
          };
          hardeningDisable = [ "strictoverflow" ];
        });
      });
      ocamlPackages_5_0 = ocaml-ng.ocamlPackages_5_0.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "5.0.0";
            hash = "sha256-pQrbncjIYrrreJS7LV+Z5J0AhAikD+94MHnZ3ChHF9w=";
          };

        });
      });
      ocamlPackages_5_1 = ocaml-ng.ocamlPackages_5_1.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "5.1.1";
            hash = "sha256-uSmTpDUVhj9niON65B9sc/8PBgurS3nIOx4dJjJiUqc=";
          };
        });
      });

      ocamlPackages_5_2 = ocaml-ng.ocamlPackages_5_2.overrideScope (oself: osuper: {
        ocaml = osuper.ocaml.overrideAttrs (_: {
          src = super.fetchFromGitHub {
            owner = "ocaml";
            repo = "ocaml";
            rev = "5.2.1";
            hash = "sha256-SjTHht2s9Vc5fIfkWkHwOl7qgaNY72qt1TX5hco42Zs=";
          };
        });
      });

      ocamlPackages_5_3 = newOCamlScope {
        major_version = "5";
        minor_version = "3";
        patch_version = "0";
        hardeningDisable = [ "strictoverflow" ];
        src = super.fetchFromGitHub {
          owner = "ocaml";
          repo = "ocaml";
          rev = "5.3.0";
          hash = "sha256-OxvfM0OF1XjtAMgAd+4Lm67iMKV7PD1sFmGPYn/yUBY=";
        };
        postPatch = ''
          substituteInPlace "runtime/caml/camlatomic.h" \
            --replace-fail "#ifdef CAML_INTERNALS" "" \
            --replace-fail "#endif /* CAML_INTERNALS */" ""
        '';
      };

      ocamlPackages_5_4 = newOCamlScope {
        major_version = "5";
        minor_version = "4";
        patch_version = "0+beta2";
        hardeningDisable = [ "strictoverflow" ];
        src = super.fetchFromGitHub {
          owner = "ocaml";
          repo = "ocaml";
          rev = "5.4.0-beta2";
          hash = "sha256-DAggO0liHhnTor30I3tfmLay96OztibNa0e0NDrwHCM=";
        };
        postPatch = ''
          substituteInPlace "runtime/caml/camlatomic.h" \
            --replace-fail "#ifdef CAML_INTERNALS" "" \
            --replace-fail "#endif /* CAML_INTERNALS */" ""
        '';
      };

      ocamlPackages_trunk = newOCamlScope {
        major_version = "5";
        minor_version = "5";
        patch_version = "0+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = super.fetchFromGitHub {
          owner = "ocaml";
          repo = "ocaml";
          rev = "b386fd53a7c6c198b8ef45b564040a48723c5b9e";
          hash = "sha256-CT1UNdsw6KzMiuerPdPcWKz36E+Cbit3XrQMjokCXl4=";
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
    ocamlPackages_latest = oPs.ocamlPackages_5_2;
  };
  ocamlPackages =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackages
    else ocaml-ng.ocamlPackages_5_2;
  ocamlPackages_latest =
    if updateOCamlPackages then
      overlaySinglePackageSet super.ocamlPackage_latest
    else
      ocaml-ng.ocamlPackages_latest;
  ocaml = ocamlPackages.ocaml;
}
