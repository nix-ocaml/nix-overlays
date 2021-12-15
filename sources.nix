{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-14";
    url = https://github.com/nixos/nixpkgs/archive/cfdb99fe18a.tar.gz;
    sha256 = "19rvn8cw29y0ay01x941pnp6jqdgwq8h4klrwd6bwh7hdpkvsbf3";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
