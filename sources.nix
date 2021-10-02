{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-01";
    url = https://github.com/nixos/nixpkgs/archive/82155ff501c.tar.gz;
    sha256 = "0xv47cpgaxb4j46ggjx9gkg299m9cdfzar27xw5h5k2lg5d3dljg";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
