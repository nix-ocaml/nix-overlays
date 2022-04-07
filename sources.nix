{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-06";
    url = https://github.com/nixos/nixpkgs/archive/a64987375ffc8e9cc093150596c9bee215e4d6f4.tar.gz;
    sha256 = "073s1zv1gf2njk7qgzzlz1lizgfi19j32fxd516x5iin54mk714v";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
