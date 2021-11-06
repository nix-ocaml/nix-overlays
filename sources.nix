{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-05";
    url = https://github.com/nixos/nixpkgs/archive/7c8883cf2d45.tar.gz;
    sha256 = "1g7j9rz2gncykp46ap5cvx6v10ydvfs6xda8c0vgl0fwicikiv4m";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
