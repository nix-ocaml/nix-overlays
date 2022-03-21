{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-20";
    url = https://github.com/nixos/nixpkgs/archive/e2f381b2f1879ad6d68be5a9e9e6e3288529bfaf.tar.gz;
    sha256 = "0h262iqg0v472gc05fzzyhn8fpqb430klgxpl9pmg44kx0bx1a69";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
