#!/usr/bin/env bash
set -euo pipefail

args=(
  --flake ".#hydraJobs.${1}.${2}"
  # --no-link
  # --eval-workers 4
  # --skip-cached
  # --no-nom
  # --option allow-import-from-derivation false
  # --eval-max-memory-size "12000"
  # --quiet-build
)

OCAMLRUNPARAM=b nix run github:anmonteiro/nix-ci-build -- "${args[@]}"
