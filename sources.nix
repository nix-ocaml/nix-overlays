{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-02";
    url = https://github.com/nixos/nixpkgs/archive/b165ce0c4ef.tar.gz;
    sha256 = "1q7n9rk4i8ky2xxiymm72cfq1xra3ss3vkhbwf60rhiblslldgqg";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
