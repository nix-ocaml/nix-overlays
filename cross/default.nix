{ lib, buildPackages, callPackage }:

[
  (lib.overlayOcamlPackages (callPackage ./ocaml.nix { }))
  (self: super: {
    opaline = buildPackages.opaline;
  })

]
