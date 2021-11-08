{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-07";
    url = https://github.com/nixos/nixpkgs/archive/c935f5e0add.tar.gz;
    sha256 = "1jwv20dxiaiwfqsa2jryib20d7ggvy5kfggna3cam6mafbpvad18";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
