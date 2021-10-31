{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-16";
    url = https://github.com/nixos/nixpkgs/archive/4fe24a325d8.tar.gz;
    sha256 = "1zvj1nhwxf8yi8m5yl48gg82krij0gy27hnfi7bhgci792wp5b6x";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
