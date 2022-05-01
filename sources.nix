let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  src = {
    inherit (lock.nodes.nixpkgs.locked) rev narHash;
  };
in
{
  unstable = builtins.fetchTarball {
    name = "undefined-2022-04-28";
    url = "https://github.com/nixos/nixpkgs/archive/${src.rev}.tar.gz";
    sha256 = src.narHash;
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
