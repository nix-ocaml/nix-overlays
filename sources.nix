{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-16";
    url = https://github.com/nixos/nixpkgs/archive/931ab058daa7.tar.gz;
    sha256 = "079925kw711k8agg17kxq36ininpacfjjhgydjy0pqbkhk59v6gm";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
