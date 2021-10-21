{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-16";
    url = https://github.com/nixos/nixpkgs/archive/3ef1d2a9602.tar.gz;
    sha256 = "0ajd2lzsjxw2zdc35a5xw8ci0k5vizj63xvxnpya2m45wr9dn5rj";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
