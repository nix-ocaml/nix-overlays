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
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml/ocaml/archive/601fb71a73c488a4dadd1ea66c7e6d905f27dd17.tar.gz;
          sha256 = "1xb5svd3nll8njn75l9k2sk8kzkdfxp3d73ybhjkndym1pv9w5zp";
        };
      });

    })).overrideScope' (callPackage ./. { });
  };
}
