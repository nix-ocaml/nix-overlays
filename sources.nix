{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-02-27";
    url = https://github.com/nixos/nixpkgs/archive/9783ef3.tar.gz;
    sha256 = "1v96lrhsjq76xxmn7bv1vkqb5nbg6qnm03bqqx02cz6bmvgbzwyy";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
