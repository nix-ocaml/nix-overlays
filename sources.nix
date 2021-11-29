{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-21";
    url = https://github.com/nixos/nixpkgs/archive/942eb9a335b.tar.gz;
    sha256 = "05390093gl44h8v6pgklwkgbn3vwdhs81shabqmjagq6rg1sh1l5";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
