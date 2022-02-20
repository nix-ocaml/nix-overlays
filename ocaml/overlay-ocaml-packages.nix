let
  ocamlVersions = [ "4_06" "4_08" "4_09" "4_10" "4_11" "4_12" "4_13" "5_00" ];
in

extraOverlays:

self: super:

let
  inherit (super) lib callPackage;

  ocaml-ng_with_500 =
    super.ocaml-ng //
    (if !(super.ocaml-ng ? "ocamlPackages_5_00") then {
      ocamlPackages_5_00 = super.ocaml-ng.ocamlPackages_4_13.overrideScope' (oself: osuper:
        let
          sources = "${import ../sources.nix}/pkgs/development/compilers/ocaml/generic.nix";
        in
        {
          ocaml = (callPackage
            (import sources {
              major_version = "5";
              minor_version = "00";
              patch_version = "0+trunk";
            })
            { }).overrideAttrs
            (_: {
              version = "5.00+trunk";
              hardeningDisable = [ "strictoverflow" ];
              src = builtins.fetchurl {
                url = https://github.com/ocaml/ocaml/archive/e7b3839fcd1925473beb4bcf9cdf82c87213dc59.tar.gz;
                sha256 = "0dkv5yi78qkgr274dcrmddwm3bj1as2iz1nsg375wwy9hsd91gsj";
              };
            });
        });
    } else { });

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      builtins.foldl'
        (acc: x: acc.overrideScope' x)
        ocaml-ng_with_500."ocamlPackages_${version}"
        extraOverlays;
  };
  oPs =
    lib.fold lib.mergeAttrs { }
      (builtins.map overlayOcamlPackages ocamlVersions);

in
{
  ocaml = self.ocamlPackages.ocaml;
  ocamlPackages = oPs.ocamlPackages_4_12;
  ocamlPackages_latest = self.ocamlPackages;

  ocaml-ng = ocaml-ng_with_500 // oPs // {
    ocamlPackages = self.ocamlPackages;
  };
}
