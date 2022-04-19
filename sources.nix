{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-18";
    url = https://github.com/nixos/nixpkgs/archive/e33fe968df5a2503290682278399b1198f7ba56f.tar.gz;
    sha256 = "0kr30yj9825jx4zzcyn43c398mx3l63ndgfrg1y9v3d739mfgyw3";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
