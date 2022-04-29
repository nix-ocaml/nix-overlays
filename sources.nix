{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-28";
    url = https://github.com/nixos/nixpkgs/archive/6766fb6503ae1ebebc2a9704c162b2aef351f921.tar.gz;
    sha256 = "1a805n9iqlbmffkzq3l6yf2xp74wjaz5pdcp0cfl0rhc179w4lpy";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
