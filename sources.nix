{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-24";
    url = https://github.com/nixos/nixpkgs/archive/8169990346fcd3aeb81222b7dcb70a00750d8f9f.tar.gz;
    sha256 = "0nz4vyq40anrjlnf4s58wq1hjdccya32jy1s0hkbaj07iyzs79hh";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
