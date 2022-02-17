{ lib, callPackage }:

let
  ocamlVersions = [ "4_06" "4_08" "4_09" "4_10" "4_11" "4_12" "4_13" ];
in

extraOverlays:

self: super:

let
  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      builtins.foldl'
        (acc: x: acc.overrideScope' x)
        super.ocaml-ng."ocamlPackages_${version}"
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

  ocaml-ng = super.ocaml-ng // oPs // {
    ocamlPackages = self.ocamlPackages;
    ocamlPackages_multicore = (oPs.ocamlPackages_4_12.overrideScope' (oself: osuper: {
      ocaml = osuper.ocaml.overrideAttrs (_: {
        version = "5.00+trunk";
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml/ocaml/archive/e7b3839fcd1925473beb4bcf9cdf82c87213dc59.tar.gz;
          sha256 = "0dkv5yi78qkgr274dcrmddwm3bj1as2iz1nsg375wwy9hsd91gsj";
        };
      });

    })).overrideScope' (callPackage ./. { });
  };
}
