{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-02-26";
    url = https://github.com/nixos/nixpkgs/archive/6f21ff94fc44af21973c6fdae6e03323382b7909.tar.gz;
    sha256 = "0x6pxcd3xx67x18znwnszsf5qis1gwjhrswnnx0ikgvaapg7mwfb";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
