{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-01";
    url = https://github.com/nixos/nixpkgs/archive/29f4f7110c7.tar.gz;
    sha256 = "1nf285fmg05znvlcjvk5air1zjjbkgg06m864s96h48clmiwa13r";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
