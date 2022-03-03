{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-02";
    url = https://github.com/nixos/nixpkgs/archive/d9aa42326fd.tar.gz;
    sha256 = "0kdms6gdw5w7slncijpccx0mqdg5v89pmw342cxxrdb3v4dyh1gd";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
