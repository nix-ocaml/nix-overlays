{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-30";
    url = https://github.com/nixos/nixpkgs/archive/1063244793d9b2dc3db515ac5b70a85385ec9b10.tar.gz;
    sha256 = "1qigy10v2spgkfvm45vmh6yqb1xdsq35idgrybnvjwmcyzihym3n";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
