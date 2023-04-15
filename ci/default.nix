{ ocamlVersion, target ? "native" }:
let

  system = builtins.currentSystem;
  flake = (import
    (fetchTarball {
      url = https://github.com/edolstra/flake-compat/archive/35bb57c0.tar.gz;
      sha256 = "1prd9b1xx8c0sfwnyzkspplh30m613j42l1k789s521f4kv4c2z2";
    })
    { src = ../.; }).defaultNix;

  pkgs = flake.legacyPackages.${system}.extend (final: prev:
    if ocamlVersion != null && prev.lib.hasPrefix "5_" ocamlVersion then {
      ocamlPackages = final.ocaml-ng."ocamlPackages_${ocamlVersion}";
    } else { });
  filter = pkgs.callPackage ./filter.nix { };
  inherit (pkgs) lib stdenv pkgsCross;

in

{
  top-level-packages = [ pkgs.esy ] ++ lib.optional stdenv.isLinux pkgs.kubernetes;

  native = (lib.attrValues (filter.ocamlCandidates {
    inherit pkgs ocamlVersion;
  }))
  ++ lib.optional (ocamlVersion == "4_14") pkgs.ocamlPackages.melange;

  musl = filter.crossTargetList pkgsCross.musl64 ocamlVersion;

  arm64 = filter.crossTargetList pkgsCross.aarch64-multiplatform-musl ocamlVersion;

}."${target}"
