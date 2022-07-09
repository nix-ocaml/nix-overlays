{ buildPackages }:

[
  (self: super:
    let
      inherit (super) lib;
      overlays = (import ./ocaml.nix {
        inherit buildPackages;
        inherit (super) lib
          writeText
          writeScriptBin
          stdenv
          bash;
      });
    in
    (lib.overlayOCamlPackages {
      inherit super overlays;
      updateOCamlPackages = true;
    }))
  (self: super: {
    opaline = buildPackages.opaline;
  })
]
