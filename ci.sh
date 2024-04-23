#!/usr/bin/env bash
set -euo pipefail

args=(
  --flake ".#hydraJobs.${1}.${2}"
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

OCAMLRUNPARAM=b nix run github:nix-ocaml/nix-ci-build -- "${args[@]}"
