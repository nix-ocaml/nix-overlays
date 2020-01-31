{ stdenv, reason, fetchFromGitHub, ninja, nodejs, python3, ... }:

stdenv.mkDerivation rec {
  pname = "bs-platform";
  version = "7.0.2-dev.1";

  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "f624ac892da4f07264306ba0645c53ac601c2974";
    sha256 = "18ms9fzd9mqynw29x7wbsbs9qc4jj6skvmyr89yny2miafxycdp0";
    fetchSubmodules = true;
  };

  BS_RELEASE_BUILD = "true";
  buildInputs = [ nodejs python3 ];

  patchPhase =
    let
      ocaml-version = "4.06.1";
      ocaml = import ./ocaml.nix {
        bs-version = version;
        version = ocaml-version;
        inherit stdenv;
        src = "${src}/ocaml";
      };
    in
    ''
      sed -i 's:./configure.py --bootstrap:python3 ./configure.py --bootstrap:' ./scripts/install.js
      mkdir -p ./native/${ocaml-version}/bin
      ln -sf ${ocaml}/bin/*  ./native/${ocaml-version}/bin
      rm -f vendor/ninja/snapshot/ninja.linux
      cp ${ninja}/bin/ninja vendor/ninja/snapshot/ninja.linux
    '';

  configurePhase = ''
    node scripts/ninja.js config
  '';

  buildPhase = ''
    node scripts/install.js
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -rf jscomp lib vendor odoc_gen native $out
    cp bsconfig.json package.json $out
    ln -s $out/lib/bsb $out/bin/bsb
    ln -s $out/lib/bsc $out/bin/bsc
    ln -s ${reason}/bin/refmt $out/bin/bsrefmt
  '';
}
