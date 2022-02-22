{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-22";
    url = https://github.com/nixos/nixpkgs/archive/d5f237872975e6fb6f76eef1368b5634ffcd266f.tar.gz;
    sha256 = "0fsjwhqgxyd2v86glr2560gr3zx9mb6fhllydmrxi5i04c549vsr";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
