{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-05";
    url = https://github.com/nixos/nixpkgs/archive/4dddff0976bc8d3ef077d81bc44f00796b49e395.tar.gz;
    sha256 = "1lqzycykzi31fqmlgrvy26q7j5rwm8crxmyvjglyrii4167acic3";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
