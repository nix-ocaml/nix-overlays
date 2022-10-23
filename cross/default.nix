{ buildPackages }:

[
  (self: super:
    let
      inherit (super) lib callPackage;
      overlays = (callPackage ./ocaml.nix {
        inherit buildPackages;
        inherit (super) lib
          writeText
          writeScriptBin
          stdenv;
      });
    in
    lib.overlayOCamlPackages {
      inherit super overlays;
      updateOCamlPackages = true;
    })
]
