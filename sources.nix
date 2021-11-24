{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-21";
    url = https://github.com/nixos/nixpkgs/archive/db22325869a.tar.gz;
    sha256 = "0pihqkl1c5bmb62657r38irvacav51ab0r4vfa2wn027ch1ry29m";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
