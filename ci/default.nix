{ ocamlVersion, target ? "native" }:
let

  flake = (import
    (fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/b4a3401.tar.gz";
      sha256 = "1qc703yg0babixi6wshn5wm2kgl5y1drcswgszh4xxzbrwkk9sv7";
    })
    { src = ../.; }).defaultNix;

  pkgs = flake.legacyPackages."${builtins.currentSystem}";

  filter = import ./filter.nix { inherit pkgs; };

in
with pkgs;
with filter;
{
  native = lib.attrValues (buildCandidates { inherit pkgs ocamlVersion; extraIgnores = (if ocamlVersion == "5_00" then ocaml5Ignores else [ ]); }) ++ [
    # cockroachdb-21_1_x cockroachdb-21_2_x
    cockroachdb-22_x
    # mongodb-4_2
    # nixUnstable
    esy
  ] ++ lib.optional stdenv.isLinux [ kubernetes ];

  musl = crossTargetList pkgs.pkgsCross.musl64 ocamlVersion;

  arm64 = crossTargetList pkgs.pkgsCross.aarch64-multiplatform-musl ocamlVersion;

}."${target}"
