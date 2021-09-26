{ lib, ocamlVersions }:
# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

[
  (import ./overlays.nix)

  (self: super:
    let
      overlayOcamlPackages = version: {
        "ocamlPackages_${version}" =
          super.ocaml-ng."ocamlPackages_${version}".overrideScope'
            (super.callPackage ./ocaml.nix { })
        ;
      };
      oPs =
        lib.fold lib.mergeAttrs { }
          (builtins.map overlayOcamlPackages ocamlVersions);

    in
    {
      ocamlPackages = oPs.ocamlPackages_4_12;
      ocamlPackages_latest = self.ocamlPackages;

      ocaml-ng = super.ocaml-ng // oPs // {
        ocamlPackages = self.ocamlPackages;
        ocamlPackages_latest = self.ocamlPackages;
      };
    }
  )
]
