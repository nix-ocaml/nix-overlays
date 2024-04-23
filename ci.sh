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

OCAMLRUNPARAM=b nix run 'github:nix-ocaml/nix-ci-build?rev=9ae8c86500332c2b357ce6bf57e6a6fda46b6dad' -- "${args[@]}"
