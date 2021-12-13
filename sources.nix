{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-13";
    url = https://github.com/nixos/nixpkgs/archive/b0bf5f888d3.tar.gz;
    sha256 = "0l123s468r9h706grqkzf0x077r4hy6zcz529xxfiqxsh1ddx5xb";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
