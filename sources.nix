{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-22";
    url = https://github.com/nixos/nixpkgs/archive/5dbd4b2b27e24eaed6a79603875493b15b999d4b.tar.gz;
    sha256 = "0f6514l8jva85v1g1vvib93691pwr25blzxr4i4vavys5dz6kxnm";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
