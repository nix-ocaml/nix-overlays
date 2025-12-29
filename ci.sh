#!/usr/bin/env bash
set -euo pipefail

nix_ci_build() {
  local flake_ref="$1"

  if [[ -z "$flake_ref" ]]; then
    echo "usage: nix_ci_build <flake-ref>"
    return 1
  fi

  local args=(
    --flake "$flake_ref"
    --copy-to
    "s3://overlays?endpoint=https://7a53c28e9b7a91239f9ed42da04276bc.r2.cloudflarestorage.com&compression=zstd&parallel-compression=true&secret-key=${HOME}/.nix/nix-cache-key.sec"
    # --no-link
    # --eval-workers 4
    # --skip-cached
    # --no-nom
    # --option allow-import-from-derivation false
    # --eval-max-memory-size "12000"
    # --quiet-build
  )

  OCAMLRUNPARAM=b nix run \
    github:nix-ocaml/nix-ci-build \
    --override-input nixpkgs path:"$PWD" -- "${args[@]}"
}

SYSTEM="${1}"
PKG_SET="${2}"

# Build self first (to keep the cache warm)
nix_ci_build "github:nix-ocaml/nix-ci-build#packages.${SYSTEM}"

# Then build the package set
nix_ci_build ".#hydraJobs.${SYSTEM}.${PKG_SET}"
