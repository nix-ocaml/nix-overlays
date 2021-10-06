{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-10-04";
    url = https://github.com/nixos/nixpkgs/archive/f91fec348dd7.tar.gz;
    sha256 = "0kl6cz81z0jc6kzpwlbn4r2dpn25sfdvq3jykhbrbx43l4hxkz1k";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
