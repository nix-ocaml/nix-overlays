{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-21";
    url = https://github.com/nixos/nixpkgs/archive/53edfe1d1c5.tar.gz;
    sha256 = "0gnliwsj61sfgfkq2wf1llzxrchvi38vq6h8my96g5aznv49vhim";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
