{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-21";
    url = https://github.com/nixos/nixpkgs/archive/39cb89ef2ffc.tar.gz;
    sha256 = "1x9vzpay56ap4hgfq1giz00050crdngv5jkxgkxzx276mzhw93na";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
