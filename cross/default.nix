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
    (lib.overlayOcamlPackages
      overlays
      self
      super))
  (self: super: {
    opaline = super.buildPackages.opaline;
  })
]
