{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-08";
    url = https://github.com/nixos/nixpkgs/archive/9bf75dd50b7b.tar.gz;
    sha256 = "0ii3z5v9p21la8gc8l136s5rax932awz7mk757jciai766lp2fhz";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
