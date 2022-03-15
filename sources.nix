{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-14";
    url = https://github.com/nixos/nixpkgs/archive/3239fd2b8f72.tar.gz;
    sha256 = "0bn0dcd7casv9kwxpa22mxizs8gmrpgi5xba0qr7g6fi7l5lnp1v";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
