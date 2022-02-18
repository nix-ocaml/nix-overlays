{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-17";
    url = https://github.com/nixos/nixpkgs/archive/4c999b91a5f.tar.gz;
    sha256 = "1z9ms3xjnpcg5gh265wh56bm05xa10j8llifizkbwzvq96jz8y9k";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
