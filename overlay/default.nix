# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
final: prev:

let
  overlay = import ./overlay.nix nixpkgs;
  self = overlay final prev;
  super = self;
in

self
// {

  # Cross-compilation / static overlays
  # pkgsMusl = prev.pkgsMusl.appendOverlays [
  # overlay
  # # (import ../static)
  # # (prev.pkgsMusl.callPackage ../static/ocaml.nix { })
  # ];
  pkgsStatic = prev.pkgsStatic.extend (
    self: super:
    super.lib.overlayOCamlPackages {
      inherit self super;
      overlays = [ ];
      # overlays = [ (super.callPackage ../static/ocaml.nix { }) ];
      updateOCamlPackages = true;
    }
  );

  pkgsCross =
    let
      static-overlay = import ../static;
    in
    prev.pkgsCross
    // {
      aarch64-multiplatform =
        let
          cross-overlay = (prev.callPackage ../cross { });
        in
        prev.pkgsCross.aarch64-multiplatform.extend cross-overlay;
      aarch64-multiplatform-musl =
        let
          cross-overlay = (prev.pkgsMusl.callPackage ../cross { });
        in
        prev.pkgsCross.aarch64-multiplatform-musl.appendOverlays [
          cross-overlay
          static-overlay
        ];
      musl64 = prev.pkgsCross.musl64.extend static-overlay;
      riscv64 = prev.pkgsCross.riscv64.extend (super.callPackage ../cross { });
    };

}
