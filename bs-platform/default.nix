{ stdenv, reason, fetchFromGitHub, ninja, nodejs, python3, gnutar, ... }:

let
  bin_folder = if stdenv.isDarwin then "darwin" else "linux";
in
stdenv.mkDerivation rec {
  pname = "bs-platform";
  version = "7.3.2";

  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = version;
    sha256 = "1nvp7wiiv149r4qf9bgc84bm4w7s44sjq9i7j103v24wllzz218s";
    fetchSubmodules = true;
  };

  BS_RELEASE_BUILD = "true";
  BS_TRAVIS_CI = "1";
  buildInputs = [ nodejs python3 gnutar ];

  patches = [
    # This is https://github.com/BuckleScript/bucklescript/pull/4047 rebased
    # against the current version of BuckleScript
    ./patches/0001-watch-symlinked-dirs.patch

    # This patch is sort of a hack to just watch all the dependent (linked)
    # directories in a monorepo instead of looking for
    # `node_modules/<package>/lib/bs/.sourcedirs.json`, which won't be present
    # for dependencies in `node_modules` (BuckleScript only builds them at the
    # top level).
    ./patches/0002-watch-all-dep-dirs.patch
  ];

  postPatch =
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
    '';

  dontConfigure = true;

  buildPhase = ''
    node scripts/install.js
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -rf jscomp lib ${bin_folder} vendor odoc_gen native bsb bsc $out
    mkdir -p $out/lib/ocaml
    cp jscomp/runtime/js.* jscomp/runtime/*.cm* $out/lib/ocaml
    cp jscomp/others/*.ml jscomp/others/*.mli jscomp/others/*.cm* $out/lib/ocaml
    cp jscomp/stdlib-406/*.ml jscomp/stdlib-406/*.mli jscomp/stdlib-406/*.cm* $out/lib/ocaml
    cp bsconfig.json package.json $out
    ln -s $out/bsb $out/bin/bsb
    ln -s $out/bsc $out/bin/bsc
    ln -s ${reason}/bin/refmt $out/bin/bsrefmt
  '';
}
