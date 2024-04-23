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

OCAMLRUNPARAM=b nix run 'github:anmonteiro/nix-ci-build?rev=aedec8d2dbaf7988a9e16d35c09256f8145c3aa8' -- "${args[@]}"
