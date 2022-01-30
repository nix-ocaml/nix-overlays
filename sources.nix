{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-01-29";
    url = https://github.com/nixos/nixpkgs/archive/5bb20f9dc70e.tar.gz;
    sha256 = "0h92fdz44y12cqx2c3qnccik4zlzp55xb4ywgdlr99pzbxf74jrv";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
