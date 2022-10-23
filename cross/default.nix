{ buildPackages }:

self: super:

super.lib.overlayOCamlPackages {
  inherit super;
  overlays = super.callPackage ./ocaml.nix {
    inherit buildPackages;
  };
  updateOCamlPackages = true;
}
