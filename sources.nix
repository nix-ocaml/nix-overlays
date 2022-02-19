{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-17";
    url = https://github.com/nixos/nixpkgs/archive/97777606991.tar.gz;
    sha256 = "0b3ryy94m7hl1rcxki094zccngbf68h6pqswvpyid9a89mcy9q93";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
