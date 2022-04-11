{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-04-11";
    url = https://github.com/nixos/nixpkgs/archive/1693e55bd218f2d055d82f4485f67d99521cf70a.tar.gz;
    sha256 = "0626n2s19xb00hx761piyagaqbmn65bkw5nc3jvhkvd1syqpj0az";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
