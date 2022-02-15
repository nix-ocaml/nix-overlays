{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-13";
    url = https://github.com/nixos/nixpkgs/archive/2b8555151a90.tar.gz;
    sha256 = "1hq483rnv67i682yqr83vmpz5rw4xpx3frspslx3lzzbd6w8cbnh";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
