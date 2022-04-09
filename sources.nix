{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-08";
    url = https://github.com/nixos/nixpkgs/archive/e10e367defcb64675f021e82cc9e0a0f4ec4f0b4.tar.gz;
    sha256 = "0pxmhbdg105ysy8p145mggff2n081r0s5x9w4sydbz9vh1jghna4";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
