{ lib, ocamlVersions }:

[
  (self: super:
    let
      overlayOcamlPackages = version: {
        "ocamlPackages_${version}" =
          super.ocaml-ng."ocamlPackages_${version}".overrideScope'
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
      opaline = super.opaline.override {
        inherit (self) ocamlPackages;
      };

      ocaml-ng = super.ocaml-ng // oPs // {
        ocamlPackages = self.ocamlPackages;
        # ocamlPackages_latest = self.ocamlPackages;
      };
    })
]
