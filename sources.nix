{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-14";
    url = https://github.com/nixos/nixpkgs/archive/69958994ab2c.tar.gz;
    sha256 = "1rw6sxgiisj5pg9kii3awd5km8wk4h7ldxch7m5pq36p03k11ghq";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
