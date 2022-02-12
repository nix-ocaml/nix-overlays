{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-11";
    url = https://github.com/nixos/nixpkgs/archive/48d63e924a2.tar.gz;
    sha256 = "0dcxc4yc2y5z08pmkmjws4ir0r2cbc5mha2a48bn0bk7nxc6wx8g";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
