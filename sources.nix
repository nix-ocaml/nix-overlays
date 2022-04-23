{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-22";
    url = https://github.com/nixos/nixpkgs/archive/f6afd49aa339caabf62b83c9c9f305b5d751b517.tar.gz;
    sha256 = "1ks0rg34pfpjbk6r36774zv69cdqrgb6ssmhs82ci602wp8gfb79";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
