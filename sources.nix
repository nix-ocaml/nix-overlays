{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-18";
    url = https://github.com/nixos/nixpkgs/archive/d609c9c79e467929282a14c4226f823868e2672c.tar.gz;
    sha256 = "15ppvfg6a8dcyzly665yvd1pcqfs5v124fnxj4w6imj0fng2i99x";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
