{ ocamlVersion, target ? "native" }:
let

  system = builtins.currentSystem;
  flake = (import
    (fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/b4a3401.tar.gz";
      sha256 = "1qc703yg0babixi6wshn5wm2kgl5y1drcswgszh4xxzbrwkk9sv7";
    })
    { src = ../.; }).defaultNix;

  pkgs = flake.legacyPackages.${system}.extend (final: prev:
    if ocamlVersion != null && ocamlVersion != "5_0" then {
      ocamlPackages = final.ocaml-ng."ocamlPackages_${ocamlVersion}";
    } else { });
  filter = pkgs.callPackage ./filter.nix { };
  inherit (pkgs) lib stdenv pkgsCross;

in

{
  top-level-packages = (with pkgs; [
    cockroachdb-22_x
    # mongodb-4_2
    esy
  ] ++ lib.optional stdenv.isLinux pkgs.kubernetes);

  native = (lib.attrValues (filter.ocamlCandidates {
    inherit pkgs ocamlVersion;
    extraIgnores = lib.optionals (ocamlVersion == "5_0") filter.ocaml5Ignores;
  }))
  ++ lib.optional (ocamlVersion == "4_14") pkgs.ocamlPackages.melange;

  musl = filter.crossTargetList pkgsCross.musl64 ocamlVersion;

  arm64 = filter.crossTargetList pkgsCross.aarch64-multiplatform-musl ocamlVersion;

}."${target}"
