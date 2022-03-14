{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-12";
    url = https://github.com/nixos/nixpkgs/archive/720cff857be6ba07d8595b4a04f5789f9b948372.tar.gz;
    sha256 = "0qqbnzh9hkg0cckxmnxf74ndwkjhxpjkh7v6hlz0ml2z96gclmmi";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
