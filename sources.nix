{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-19";
    url = https://github.com/nixos/nixpkgs/archive/c10c8912eed56322bbe5e2124e53d0361d2017cb.tar.gz;
    sha256 = "0qamglsw9s548m3d39v2qigb43c1ilf04vykgbw0kw01xzkfhcf4";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
