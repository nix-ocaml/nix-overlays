{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-2021-11-18";
    url = https://github.com/nixos/nixpkgs/archive/42d32516400.tar.gz;
    sha256 = "0w5lya4iidnisbgphbsx0gb04safl9ai51700xl5nf8237k3nz51";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
