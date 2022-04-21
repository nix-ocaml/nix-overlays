{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-21";
    url = https://github.com/nixos/nixpkgs/archive/b06d35b406c2396dd1611dc8601138fa3d06ee60.tar.gz;
    sha256 = "18rfsd5pjjpn9ay33aj302pa4q3p7qkfs8ik6i6rks1c6236s83p";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
