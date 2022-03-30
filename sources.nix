{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-29";
    url = https://github.com/nixos/nixpkgs/archive/00e27c78d3d2de6964096ceee8d70e5b487365e3.tar.gz;
    sha256 = "0xxc4wbf3izdsmy9pw4f3nrdv2d2kwsdm269gkxik27jxlc61n61";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
