# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
final: prev:

let
  overlay = import ./overlay.nix nixpkgs;
in

overlay final prev
// {

  # Cross-compilation / static overlays

  pkgsStatic = prev.pkgsStatic.extend (
    self: super:
    super.lib.overlayOCamlPackages {
      inherit self super;
      # overlays = [ ];
      overlays = [ (super.callPackage ../static/ocaml.nix { }) ];
      updateOCamlPackages = true;
    }
  );

  pkgsCross =
    let
      static-overlay = import ../static;
      musl64 = prev.pkgsCross.musl64.extend static-overlay;
      native-musl-cc =
        let
          cc = musl64.stdenv.cc;
        in
        prev.runCommand "native-musl-cc-wrapper" { } ''
          mkdir -p $out/bin
          for tool in ${cc}/bin/${cc.targetPrefix}*; do
            name="''${tool##*/}"
            ln -s "$tool" "$out/bin/$name"
            ln -s "$tool" "$out/bin/''${name#${cc.targetPrefix}}"
          done
        '';
      musl-cross-overlay = prev.callPackage ../cross {
        buildPackages = prev.buildPackages;
        nativeCC = native-musl-cc;
        nativeOCamlPackageSets = musl64.ocaml-ng;
      };
    in
    prev.pkgsCross
    // {
      aarch64-multiplatform =
        let
          cross-overlay = (prev.callPackage ../cross { });
        in
        prev.pkgsCross.aarch64-multiplatform.extend cross-overlay;

      aarch64-multiplatform-musl = prev.pkgsCross.aarch64-multiplatform-musl.appendOverlays [
        musl-cross-overlay
        static-overlay
      ];

      inherit musl64;

      riscv64 = prev.pkgsCross.riscv64.extend (prev.callPackage ../cross { });
      riscv64-musl = prev.pkgsCross.riscv64-musl.appendOverlays [
        musl-cross-overlay
        static-overlay
      ];

      mingwW64 = prev.pkgsCross.mingwW64.extend (prev.callPackage ../cross { });

      mingwW64Static =
        let
          cross-overlay = (prev.callPackage ../cross { });
        in
        prev.pkgsCross.mingwW64.appendOverlays [
          cross-overlay
          static-overlay
        ];
    };
}
