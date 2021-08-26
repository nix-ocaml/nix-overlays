{ lib, fetchzip, pkgs, stdenv, ocamlPackages }:

let
  src = fetchzip {
    url = https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.4.1/hacl-star.0.4.1.tar.gz;
    sha256 = "sha256-05djOEIw6tLWP7eQPczUJjedyeVVJyvxPjpyTmkXlRY=";
    stripRoot = false;
  };

in

{
  hacl-star = ocamlPackages.buildDunePackage {
    sourceRoot = ".";
    pname = "hacl-star";
    version = "0.4.1";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      hacl-star-raw
      zarith
    ];

    buildInputs = with ocamlPackages; [
      cppo
    ];

    doCheck = true;

    meta = {
      description = "Auto-generated low-level OCaml bindings for EverCrypt/HACL*";
      license = lib.licenses.asl20;
    };
  };


  hacl-star-raw = stdenv.mkDerivation {
    pname = "hacl-star-raw";
    version = "0.4.1";
    inherit src;

    sourceRoot = "./source/raw";

    postPatch = ''
      patchShebangs ./
    '';

    preInstall = ''
      mkdir -p $OCAMLFIND_DESTDIR/stublibs
    '';

    propagatedBuildInputs = with ocamlPackages; [
      ctypes
    ];

    installTargets = "install-hacl-star-raw";

    dontAddPrefix = true;

    checkInputs = with ocamlPackages; [
      cppo
    ];

    buildInputs = [
      pkgs.which
      ocamlPackages.ocaml
      ocamlPackages.findlib
    ];

    meta = {
      description = "Auto-generated low-level OCaml bindings for EverCrypt/HACL*";
      license = lib.licenses.asl20;
    };
  };
}
