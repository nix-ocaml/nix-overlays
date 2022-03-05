{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-02";
    url = https://github.com/nixos/nixpkgs/archive/3c745c05fb1d.tar.gz;
    sha256 = "1p7p93mwaf1im82lva2j7kvl318f5668khza0g4drz70zbjirpkf";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
