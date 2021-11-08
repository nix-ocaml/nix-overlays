{ lib, buildPackages, ocamlVersions }:

[
  (self: super:
    let
      overlayOcamlPackages = version: {
        "ocamlPackages_${version}" =
          builtins.foldl'
            (acc: x: acc.overrideScope' x)
            super.ocaml-ng."ocamlPackages_${version}"
            (super.callPackage ./ocaml.nix {
              inherit buildPackages;
            });
      };
      oPs =
        lib.fold lib.mergeAttrs { }
          (builtins.map overlayOcamlPackages ocamlVersions);

    in
    {
      ocaml = self.ocamlPackages.ocaml;
      ocamlPackages = oPs.ocamlPackages_4_12;
      ocamlPackages_latest = self.ocamlPackages;
      opaline = buildPackages.opaline;

      ocaml-ng = super.ocaml-ng // oPs // {
        ocamlPackages = self.ocamlPackages;
        ocamlPackages_latest = self.ocamlPackages;
      };
    })
]
