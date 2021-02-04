#!/usr/bin/env bash

set -x

find . -iname '*.nix' | xargs nix run -f ./sources.nix nixpkgs-fmt -c nixpkgs-fmt $@
