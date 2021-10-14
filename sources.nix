{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-08";
    url = https://github.com/nixos/nixpkgs/archive/2ae14350dd34.tar.gz;
    sha256 = "0p8vc1p45xw063a22wl4jqikmsjbyga8a8zf1npyswday95156ax";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
