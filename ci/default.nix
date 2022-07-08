{ ocamlVersion, target ? "native", index ? null }:
let
  parallelism = 4;

  system = builtins.currentSystem;
  flake = (import
    (fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/b4a3401.tar.gz";
      sha256 = "1qc703yg0babixi6wshn5wm2kgl5y1drcswgszh4xxzbrwkk9sv7";
    })
    { src = ../.; }).defaultNix;

  pkgs = flake.legacyPackages.${system}.extend (self: super:
    if ocamlVersion != null && ocamlVersion != "5_00" then {
      ocamlPackages = self.ocaml-ng."ocamlPackages_${ocamlVersion}";
      ocamlPackages_latest = self.ocamlPackages;
    } else { });
  filter = pkgs.callPackage ./filter.nix { };
  inherit (pkgs) lib stdenv pkgsCross;

  package-set = {
    top-level-packages = (with pkgs; [
      cockroachdb-22_x
      # mongodb-4_2
      esy
    ] ++ lib.optional stdenv.isLinux pkgs.kubernetes);

    native = (lib.attrValues (filter.ocamlCandidates {
      inherit pkgs ocamlVersion;
      extraIgnores =
        lib.optionals (ocamlVersion == "5_00") filter.ocaml5Ignores
          ++ lib.optionals (ocamlVersion == "4_12") filter.ocaml412Ignores;
    }))
    ++ lib.optional (ocamlVersion == "4_14") pkgs.ocamlPackages.melange;

    musl = filter.crossTargetList pkgsCross.musl64 ocamlVersion;

    arm64 = filter.crossTargetList pkgsCross.aarch64-multiplatform-musl ocamlVersion;
  };

  allPackages = package-set.${target};
in

if index == null then allPackages
else
  let
    len = lib.length allPackages;
    partitionLen = len / parallelism;
    dropped = (lib.drop (index * partitionLen) allPackages);
  in
  lib.trace
    ''
      len: ${builtins.toString len};
      dropped: ${builtins.toString (lib.length dropped)};
      partitionLen: ${builtins.toString partitionLen};
    ''
    (lib.take partitionLen dropped)
