{ buildPackages }:

self: super:

super.lib.overlayOCamlPackages {
  inherit self super;
  overlays = super.callPackage ./ocaml.nix {
    inherit buildPackages;
  };
  updateOCamlPackages = true;
}
