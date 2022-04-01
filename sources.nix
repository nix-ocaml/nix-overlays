{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-03-31";
    url = https://github.com/nixos/nixpkgs/archive/710fed5a2483f945b14f4a58af2cd3676b42d8c8.tar.gz;
    sha256 = "1xhbkgb9rzh2b0rbyhcygvc6216g9qbqyjkkgrhwfclsx06sfach";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
