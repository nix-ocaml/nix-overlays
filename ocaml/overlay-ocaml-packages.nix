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
        version = "4.12.0+multicore+effects";
        # hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml-multicore/ocaml-multicore/archive/9468d8c91feac55c9b390e50c25b739de043e5e0.tar.gz;
          sha256 = "0zymc0rm5kmydr97jdjbj0wdvlb0ldw57f2i7d915vf8xd0xz9ba";
        };
      });
    })).overrideScope' (callPackage ./. { });
  };
}
