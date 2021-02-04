{ stdenv, ocamlPackages, fetchFromGitHub, nodejs, python3, gnutar, ... }:

with ocamlPackages;
let
  bin_folder = if stdenv.isDarwin then "darwin" else "linux";
in
stdenv.mkDerivation rec {
  pname = "bs-platform";
  version = "8.2.0";

  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = version;
    sha256 = "1hql7sxps1k17zmwyha6idq6nw20abpq770l55ry722birclmsmf";
    fetchSubmodules = true;
  };

  BS_RELEASE_BUILD = "true";
  BS_TRAVIS_CI = "1";
  buildInputs = [ nodejs python3 gnutar ];

  patches = [
    ./patches/0003-generators-in-dependencies.patch
    ./patches/0004-ninja-install.patch
    ./patches/0006-jscomp-release-ninja-fix.patch
  ];

  postPatch =
    ''
      cp ${./patches/0005-ninja-lexer.patch} ./ninja.patch
      # Don't keep these things in the nix store
      rm -rf ./darwin ./linux ./win32
      mkdir ./${bin_folder}

      # Don't build refmt, we have our own.
      sed -i 's#build ../.{process.platform}/refmt$ext: cc $INCL/refmt_main3.mli $INCL/refmt_main3.ml##g' ./scripts/ninjaFactory.js
      sed -i 's#    flags = $flags  -w -40-30 -no-alias-deps -I +compiler-libs ocamlcommon.cmxa##g' ./scripts/ninjaFactory.js

      # But BuckleScript needs it to build
      rm -rf ./${bin_folder}/refmt.exe
      ln -s ${reason}/bin/refmt ./${bin_folder}/refmt.exe

      sed -i 's:./configure.py --bootstrap:python3 ./configure.py --bootstrap:' ./scripts/install.js
      mkdir -p ./native/${ocaml-version}/bin
      ln -sf ${ocaml}/bin/*  ./native/${ocaml-version}/bin
    '';

  dontConfigure = true;

  buildPhase = ''
    node scripts/install.js
  '';

  installPhase = ''
    mkdir -p $out/bin $out/${bin_folder}
    cp -rf jscomp lib ${bin_folder} vendor odoc_gen native bsb bsc $out
    mkdir -p $out/lib/ocaml
    cp jscomp/runtime/js.* jscomp/runtime/*.cm* $out/lib/ocaml
    cp jscomp/others/*.ml jscomp/others/*.mli jscomp/others/*.cm* $out/lib/ocaml
    cp jscomp/stdlib-406/*.ml jscomp/stdlib-406/*.mli jscomp/stdlib-406/*.cm* $out/lib/ocaml
    cp bsconfig.json package.json $out
    ln -sfn $out/bsb $out/bin/bsb
    ln -sfn $out/bsc $out/bin/bsc
    ln -sfn ${reason}/bin/refmt $out/bin/bsrefmt
    rm -rf $out/${bin_folder}/refmt.exe
    ln -sfn ${reason}/bin/refmt $out/${bin_folder}/refmt.exe
    ln -sfn $out/${bin_folder}/* $out/bin
  '';
}
