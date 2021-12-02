{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-12-02";
    url = https://github.com/nixos/nixpkgs/archive/58371472fe7.tar.gz;
    sha256 = "0x50f6cqydy2s9w6cziq9hn1l3fdshxd8i6d3r9p6zbjnkdzblb3";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
