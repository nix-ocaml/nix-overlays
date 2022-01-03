{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-01-02";
    url = https://github.com/nixos/nixpkgs/archive/59bfda724804.tar.gz;
    sha256 = "18akd1chfvniq1q774rigfxgmxwi0wyjljpa1j9ls59szpzr316d";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
