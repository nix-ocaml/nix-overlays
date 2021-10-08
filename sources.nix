{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-07";
    url = https://github.com/nixos/nixpkgs/archive/6755a884b240.tar.gz;
    sha256 = "1jxc2mmgs8bll8vpzl23ds2ppr4fdza77b1m1748qfi3wv7bs39k";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
