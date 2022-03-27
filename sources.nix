{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-26";
    url = https://github.com/nixos/nixpkgs/archive/a34c788e30fffdbc808e4706bcf50b625af2686a.tar.gz;
    sha256 = "13vr0j040sxy48h1y8prz4jr1k5zswknmc0xsnrcr70h40gx0z87";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
