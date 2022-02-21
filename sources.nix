{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-20";
    url = https://github.com/nixos/nixpkgs/archive/d0ae0897999e.tar.gz;
    sha256 = "0cibk4pwfpspk9r40m3rnfa8j0q6g2x15bd3mriinxsa85mf45kr";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
