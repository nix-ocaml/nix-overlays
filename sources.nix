{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-20";
    url = https://github.com/nixos/nixpkgs/archive/23d785aa6f853e6cf3430119811c334025bbef55.tar.gz;
    sha256 = "00fvaap8ibhy63jjsvk61sbkspb8zj7chvg13vncn7scr4jlzd60";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
