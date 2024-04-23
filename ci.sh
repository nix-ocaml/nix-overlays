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

OCAMLRUNPARAM=b EIO_BACKEND=posix nix run 'github:nix-ocaml/nix-ci-build?rev=114abde7677119cc4c0cfbd9eb000ae5338c85a9' -- "${args[@]}"
