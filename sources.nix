{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-21";
    url = https://github.com/nixos/nixpkgs/archive/5dadb7717f34.tar.gz;
    sha256 = "16xii38qi4ry32xyrfrg5p4jxzvy3ymznvfl3l2g96kf1rpz4d7z";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
