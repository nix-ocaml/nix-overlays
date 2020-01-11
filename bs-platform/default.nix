{ stdenv, ocamlPackages_4_06, fetchFromGitHub, ninja, nodejs, python3, ... }:

let
  version = "7.0.2-dev.1";
  ocaml-version = "4.06.1";
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "f976d41902d88684ae8449bfb2af80bae7d80406";
    sha256 = "16lxpdlrn7dzqdh5srr78fg5yg2g2k8qf8hd2j1wc6bvd4k31a2q";
    fetchSubmodules = true;
  };
  ocaml = import ./ocaml.nix {
    bs-version = version;
    version = ocaml-version;
    inherit stdenv;
    src = "${src}/ocaml";
  };
  reason = ocamlPackages_4_06.reason;
in
stdenv.mkDerivation {
  inherit src version;
  pname = "bs-platform";
  BS_RELEASE_BUILD = "true";
  buildInputs = [ nodejs python3 ];

  patchPhase = ''
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
    node scripts/ninja.js build
  '';

  installPhase = ''
    node scripts/install.js
    mkdir -p $out/bin
    cp -rf jscomp lib vendor odoc_gen native $out
    cp bsconfig.json package.json $out
    ln -s $out/lib/bsb $out/bin/bsb
    ln -s $out/lib/bsc $out/bin/bsc
    ln -s ${reason}/bin/refmt $out/bin/bsrefmt
  '';
}
