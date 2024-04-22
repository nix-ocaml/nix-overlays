#!/usr/bin/env bash
set -euo pipefail

args=(
  --no-link
  --eval-workers 4
  --flake ".#hydraJobs.${1}.${2}"
  --skip-cached
  --no-nom
  --option allow-import-from-derivation false
  --eval-max-memory-size "12000"
  --quiet-build
)

if [[ -n "${GITHUB_STEP_SUMMARY-}" ]]; then
  log() {
    echo "$*" >> "$GITHUB_STEP_SUMMARY"
  }
else
  log() {
    echo "$*"
  }
fi

nix run github:anmonteiro/nix-fast-build?rev=036e4c3efb80ee17aa2d848ba0a0ef7d162a832c -- "${args[@]}"
