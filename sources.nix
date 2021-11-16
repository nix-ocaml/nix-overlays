{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-11";
    url = https://github.com/nixos/nixpkgs/archive/51befa6cdc7.tar.gz;
    sha256 = "1d3c625gkg2dfwxdk19ylbbq1d6kf581il1nxy381rfyrz1xklm0";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
