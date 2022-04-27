{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-27";
    url = https://github.com/nixos/nixpkgs/archive/d6b996030dd21c6509803267584b9aca3e133a07.tar.gz;
    sha256 = "1zjlnmph80i077cp1ywsfkv9p6y40f6i3dm6g3jc7f3xlq61vv4s";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
