{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-19";
    url = https://github.com/nixos/nixpkgs/archive/988b00665215.tar.gz;
    sha256 = "0a2kz6lya6jnwds6cvg1x409gciv5jd3lh1xciy3ilzaxal7ski3";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
