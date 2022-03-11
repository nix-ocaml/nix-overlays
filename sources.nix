{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-10";
    url = https://github.com/nixos/nixpkgs/archive/085e8934e46f.tar.gz;
    sha256 = "0bf403mnl2zayc3xr1hawqggsdp66yc08vfp7n15xh5bc5vpz1y8";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
