{ ocamlVersion, target ? "native" }:
let

  system = builtins.currentSystem;
  flake = (import
    (fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/b4a3401.tar.gz";
      sha256 = "1qc703yg0babixi6wshn5wm2kgl5y1drcswgszh4xxzbrwkk9sv7";
    })
    { src = ../.; }).defaultNix;

  pkgs = flake.legacyPackages.${system}.extend (self: super:
    if ocamlVersion != "5_00" then {
      ocamlPackages = self.ocaml-ng."ocamlPackages_${ocamlVersion}";
      ocamlPackages_latest = self.ocamlPackages;
    } else { });
  filter = pkgs.callPackage ./filter.nix { };
  inherit (pkgs) lib stdenv pkgsCross;

in

{
  native = lib.attrValues
    (filter.buildCandidates {
      inherit pkgs ocamlVersion;
      extraIgnores = lib.optionals (ocamlVersion == "5_00") filter.ocaml5Ignores;
    }) ++ (with pkgs; [
    # cockroachdb-21_1_x cockroachdb-21_2_x
    cockroachdb-22_x
    # mongodb-4_2
    # nixUnstable
  ]) ++ lib.optional stdenv.isLinux pkgs.kubernetes
  ++ lib.optional (ocamlVersion != "5_00") pkgs.esy;

  musl = filter.crossTargetList pkgsCross.musl64 ocamlVersion;

  arm64 = filter.crossTargetList pkgsCross.aarch64-multiplatform-musl ocamlVersion;

}."${target}"
