{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-23";
    url = https://github.com/nixos/nixpkgs/archive/7f9b6e2babf232412682c09e57ed666d8f84ac2d.tar.gz;
    sha256 = "03nb8sbzgc3c0qdr1jbsn852zi3qp74z4qcy7vrabvvly8rbixp2";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
