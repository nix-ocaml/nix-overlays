{ stdenv, reason, fetchFromGitHub, ninja, nodejs, python3, ... }:

stdenv.mkDerivation rec {
  pname = "bs-platform";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "a7f482243fabb38292b81b7bae9cefcb8076237f";
    sha256 = "0p0ywb4cjpsrjq0if4s1bsnv9jdycd61r4ryndfzc50gngrpjbqr";
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

  dontConfigure = true;

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
