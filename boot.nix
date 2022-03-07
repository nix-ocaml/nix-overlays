{ system ? null
, patches ? [ ]
, extraOverlays ? [ ]
, overlays ? [ (import ./.) ]
, ...
}@args:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

let
  systemArgs = if system == null then { } else { inherit system; };
  patchChannel = system: channel: patches:
    if patches == [ ]
    then channel
    else
      (import channel systemArgs).pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = channel;
        patches = patches;
      };
  channel = patchChannel system (import ./sources.nix) patches;

in

import channel (args // { inherit (overlays ++ extraOverlays); } // systemArgs)
