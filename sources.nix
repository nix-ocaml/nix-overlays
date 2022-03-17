{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-15";
    url = https://github.com/nixos/nixpkgs/archive/6e3ee8957637a60f5072e33d78e05c0f65c54366.tar.gz;
    sha256 = "1cvcggs6cnscs2j8xz56vqw5hvrgsr6xnw91aa4b0pv8v8im6kzp";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
