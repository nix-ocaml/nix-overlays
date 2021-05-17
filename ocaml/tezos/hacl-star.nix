{ lib, pkgs, stdenv, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.3.2/hacl-star.0.3.2.tar.gz;
    sha256 = "0iybh7nnxyf4r97px2154a2p534cxvlwxgrzi5lq7hh5mpvx6ykb";
  };

in

{
  hacl-star = ocamlPackages.buildDunePackage {
    sourceRoot = ".";
    pname = "hacl-star";
    version = "0.3.2";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      hacl-star-raw
      zarith
      cppo
    ];

    doCheck = true;

    meta = {
      description = "Auto-generated low-level OCaml bindings for EverCrypt/HACL*";
      license = lib.licenses.asl20;
    };
  };


  hacl-star-raw = stdenv.mkDerivation {
    sourceRoot = ".";
    pname = "hacl-star-raw";
    version = "0.3.2";
    inherit src;

    checkInputs = with ocamlPackages; [
      cppo
    ];

    buildInputs = [
      pkgs.which
      ocamlPackages.ocaml
      ocamlPackages.findlib
    ];

    buildPhase = ''
      sh -exc cd raw && ./configure
      make -C raw
    '';

    propagatedBuildInputs = with ocamlPackages; [
      ctypes
      ctypes
    ];

    installPhase = ''
      make -C raw install-hacl-star-raw
    '';

    createFindlibDestdir = true;

    meta = {
      description = "Auto-generated low-level OCaml bindings for EverCrypt/HACL*";
      license = lib.licenses.asl20;
    };
  };
}
