{ buildPackages }:

[
  (final: prev:
    let
      inherit (prev) lib;
      overlays = (import ./ocaml.nix {
        inherit buildPackages;
        inherit (prev) lib
          writeText
          writeScriptBin
          stdenv
          bash;
      });
    in
    lib.overlayOCamlPackages {
      inherit prev overlays;
      updateOCamlPackages = true;
    })
  (final: prev: {
    opaline = buildPackages.opaline;
  })
]
