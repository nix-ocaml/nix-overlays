{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-16";
    url = https://github.com/nixos/nixpkgs/archive/2deb07f3ac4.tar.gz;
    sha256 = "0036sv1sc4ddf8mv8f8j9ifqzl3fhvsbri4z1kppn0f1zk6jv9yi";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
