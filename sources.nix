{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-11";
    url = https://github.com/nixos/nixpkgs/archive/bcfcdaabf7f.tar.gz;
    sha256 = "0dx9d8lrsnz1b7qqhhpxh9h7dczv9nrhnz9c5aqbg4cbg6zwvqli";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
