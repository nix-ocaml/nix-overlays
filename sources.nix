{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2022-02-02";
    url = https://github.com/nixos/nixpkgs/archive/efeefb2af1469a5d1f0ae7ca8f0dfd9bb87d5cfb.tar.gz;
    sha256 = "1b3sxslv5id61phq7zx3lybw72x29bx9595i8m708fax7iml07j2";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
