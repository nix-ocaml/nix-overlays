{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-09-24";
    url = https://github.com/nixos/nixpkgs/archive/51bcdc4cdaac.tar.gz;
    sha256 = "0zpf159nlpla6qgxfgb2m3c2v09fz8jilc21zwymm59qrq6hxscm";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
