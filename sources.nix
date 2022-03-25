{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-03-23";
    url = https://github.com/nixos/nixpkgs/archive/1d08ea2bd83abef174fb43cbfb8a856b8ef2ce26.tar.gz;
    sha256 = "1q8p2bz7i620ilnmnnyj9hgx71rd2j6sjza0s0w1wibzr9bx0z05";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
