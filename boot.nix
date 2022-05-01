{ system ? null
, patches ? [ ]
, extraOverlays ? [ ]
, ...
}@args:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

let
  allPatches = [ ./add-janestreet-packages-0_15.patch ] ++ patches;
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
  nixpkgs = (import ./sources.nix);
  channel = patchChannel system nixpkgs allPatches;
  overlays = [ (import ./default.nix nixpkgs) ] ++ extraOverlays;
in

import channel (args // { inherit overlays; } // systemArgs)
