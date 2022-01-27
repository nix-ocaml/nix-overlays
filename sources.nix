{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-01-23";
    url = https://github.com/nixos/nixpkgs/archive/c07b471b52be.tar.gz;
    sha256 = "1qg18fp136rvazmiaq63ka36jb6md9d5s9y5gfi4h71l7kmdkvc8";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
