#!/usr/bin/env bash
set -euo pipefail

args=(
  --accept-flake-config
  --check-cache-status
  --gc-roots-dir gc-root
  --max-memory-size "12000"
  --option allow-import-from-derivation false
  --show-trace
  --workers 4
  --flake ".#hydraJobs.${1}.${2}"
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

error=0

for job in $(nix run .#nix-eval-jobs -- "${args[@]}" | jq -r '. | @base64'); do
  job=$(echo "$job" | base64 -d)
  attr=$(echo "$job" | jq -r .attr)
  cached=$(echo "$job" | jq -r .isCached)
  echo "### $attr (cached? $cached)"
  error=$(echo "$job" | jq -r .error)
  if [[ $error != null ]]; then
    log "### ❌ $attr"
    log
    log "<details><summary>Eval error:</summary><pre>"
    log "$error"
    log "</pre></details>"
    error=1
  else
    drvPath=$(echo "$job" | jq -r .drvPath)
    if [[ "$cached" == "true" ]]; then
      log "### ✅ $attr (in cache)"
    else
      if ! nix-store --realize "$drvPath" 2>&1 | tee build-log.txt; then
        log "### ❌ $attr"
        log
        log "<details><summary>Build error:</summary>last 50 lines:<pre>"
        log "$(tail -n 50 build-log.txt)"
        log "</pre></details>"
        error=1
        rm build-log.txt
      else
        log "### ✅ $attr"
      fi
    fi
    log
  fi
done

# TODO: improve the reporting
exit "$error"
