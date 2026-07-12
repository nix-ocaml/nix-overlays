{
  buildPackages,
  nativeCC ? buildPackages.stdenv.cc,
  nativeOCamlPackageSets ? null,
}:

self: super:

super.lib.overlayOCamlPackages {
  inherit self super;
  overlays = super.callPackage ./ocaml.nix {
    inherit buildPackages nativeCC nativeOCamlPackageSets;
  };
  updateOCamlPackages = true;
}
