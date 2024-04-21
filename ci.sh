#!/usr/bin/env bash
set -euo pipefail

args=(
  --no-link
  --eval-workers 4
  --flake ".#hydraJobs.${1}.${2}"
  --skip-cached
  --debug
  --option allow-import-from-derivation false
  --eval-max-memory-size "12000"
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

nix run github:Mic92/nix-fast-build -- "${args[@]}"
