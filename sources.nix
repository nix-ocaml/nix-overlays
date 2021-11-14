{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-11";
    url = https://github.com/nixos/nixpkgs/archive/0b239a479cd.tar.gz;
    sha256 = "0p1x6zmsh5yfz0xrkvi9nrymznnaz8l46srib271bzmcbbd2fb21";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
