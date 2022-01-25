{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-01-22";
    url = https://github.com/nixos/nixpkgs/archive/689b76bcf36.tar.gz;
    sha256 = "08d38db4707jdm3gws82y6bynh6k8qal4s1cms9zqd9cdwcmylyj";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
