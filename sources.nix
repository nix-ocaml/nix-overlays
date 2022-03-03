{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-02";
    url = https://github.com/nixos/nixpkgs/archive/3e072546ea98.tar.gz;
    sha256 = "1b51j0zz4gfcmq1lzh0f9yj6h904p7fgskshvc70dkjkdg9k2x7j";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
