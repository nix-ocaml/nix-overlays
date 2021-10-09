{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-08";
    url = https://github.com/nixos/nixpkgs/archive/9e84e5f8f36e.tar.gz;
    sha256 = "0qf1227hrn8ddv1ip3mnx8gy2lw3h2ibz82qlr96s5b048x043w9";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
