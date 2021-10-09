{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-08";
    url = https://github.com/nixos/nixpkgs/archive/70088dc29994.tar.gz;
    sha256 = "08ldqfh2cmbvf930yq9pv220sv83k9shq183935l5d8p61fxh5zr";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
