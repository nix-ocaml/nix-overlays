{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-09";
    url = https://github.com/nixos/nixpkgs/archive/a07a14ac86d.tar.gz;
    sha256 = "10k4k62mhnb985hdmlfcv6jgam783rh1ajlp8sfjyww9555f62q9";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
