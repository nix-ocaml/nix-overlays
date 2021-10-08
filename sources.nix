{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-07";
    url = https://github.com/nixos/nixpkgs/archive/5e2018f7b38.tar.gz;
    sha256 = "1i4ak2qb1q9rign398ycr190qv5ckc9inl24gf00070ykymzjs00";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
