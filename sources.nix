{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-29";
    url = https://github.com/nixos/nixpkgs/archive/9a2de8ca73e84455276d84c044791b7dbc3d77e9.tar.gz;
    sha256 = "0qxw7dzq20z5xnpnnj8v4rir0bmlgqvjxpyzdfas1237hkzjsw7v";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
