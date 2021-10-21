{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-16";
    url = https://github.com/nixos/nixpkgs/archive/3ef1d2a9602.tar.gz;
    sha256 = "0yicccl89rfa5nk4ic46ydihvzsw1phzsypnlzmzrdnwsxi3r9d4";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
