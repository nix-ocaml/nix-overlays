{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-24";
    url = https://github.com/nixos/nixpkgs/archive/eac07edbd20e.tar.gz;
    sha256 = "11r1b0kpyls2w4n7s9xkj2kim715vrk6aj7ackia4f8s9imachk6";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
