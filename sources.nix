{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-09-26";
    url = https://github.com/nixos/nixpkgs/archive/8e3b899626f3.tar.gz;
    sha256 = "0a0fdr6jxjc0i6qs8fk5mvprr170bl68089syzw01zs1jrh2qfjg";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
