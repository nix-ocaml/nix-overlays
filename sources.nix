{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-15";
    url = https://github.com/nixos/nixpkgs/archive/efe0307291c4a792951a947011f2e90038b6d116.tar.gz;
    sha256 = "1p6j8q9mq3nnb3pvsxgy8qi10jpc41hn6lkffx0kc8fiv41p9b35";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
