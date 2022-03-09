{
  unstable = builtins.fetchTarball {
    name = "nixos-unstable-small-2022-03-07";
    url = https://github.com/nixos/nixpkgs/archive/35db2e60df598e3d5c88adab65f70b91f6645b45.tar.gz;
    sha256 = "0hdrvb35bzh4yb2ykbqs44aiqwan02kcikqhsy5ay064pi1wxw2a";
  };

  staging = builtins.fetchTarball {
    name = "nixos-unstable-staging";
    url = https://github.com/nixos/nixpkgs/archive/445a2455ad.tar.gz;
    sha256 = "1ia3qnjab4vv9fpwfgkcky7fvdiqzqar00mdbvnm8va80wx127x4";
  };

  local = ../nixpkgs;
}.unstable
