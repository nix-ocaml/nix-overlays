{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-09-26";
    url = https://github.com/nixos/nixpkgs/archive/31ffc50c571e.tar.gz;
    sha256 = "1gg87k49rmdylmzxjzmllng78qr6wmssnci05z1kij3715wkqc5j";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
