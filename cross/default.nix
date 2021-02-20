{ lib, ocamlVersions }:

[
  (self: super:
    let
      overlayOcamlPackages = version: {
        "ocamlPackages_${version}" =
          builtins.foldl'
            (acc: x: acc.overrideScope' x)
            super.ocaml-ng."ocamlPackages_${version}"
            (super.callPackage ./ocaml.nix { });
      };
      oPs =
        lib.fold lib.mergeAttrs { }
          (builtins.map overlayOcamlPackages ocamlVersions);

    in
    {
      ocaml = self.ocamlPackages.ocaml;
      ocamlPackages = oPs.ocamlPackages_4_11;
      ocamlPackages_latest = self.ocamlPackages;
      opaline = super.buildPackages.opaline;

      tzdata = super.tzdata.overrideAttrs (_: {
        preInstall = ''
          mv zic.o zic.o.orig
          mv zic zic.orig
          make $makeFlags cc=cc AR=ar zic
          mv zic zic-native
          mv zic.o.orig zic.o
          mv zic.orig zic
        '';
      });

      ocaml-ng = super.ocaml-ng // oPs // {
        ocamlPackages = self.ocamlPackages;
        # ocamlPackages_latest = self.ocamlPackages;
      };
    })
]
