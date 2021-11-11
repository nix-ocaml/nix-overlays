{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-11";
    url = https://github.com/nixos/nixpkgs/archive/43b394b98e3.tar.gz;
    sha256 = "1r2s8hyhdlf2js1hlmgmmdkhb2bi0dyf9yil0xig5vz7g2ac2l47";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
