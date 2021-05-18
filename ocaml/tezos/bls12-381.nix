{ lib, ocamlPackages, ocamlVersion, pkgs }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/2f6c97bbd86ce05428e9f06ffdf3239982bd9083/ocaml-bls12-381-2f6c97bbd86ce05428e9f06ffdf3239982bd9083.tar.bz2;
    sha256 = "07x2g4p4n0hslvcsqjm3zan1v7v8l49b789szcb5l4ymcpskc4as";
  };

in

{
  bls12-381-gen = ocamlPackages.buildDunePackage {
    pname = "bls12-381-gen";
    version = "0.4.2";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      ff-sig
      zarith
    ];

    doCheck = true;

    meta = {
      description = "Functors to generate BLS12-381 primitives based on stubs";
      license = lib.licenses.mit;
    };
  };

  bls12-381 = ocamlPackages.buildDunePackage {
    pname = "bls12-381";
    version = "0.4.2";
    inherit src;

    buildInputs = with ocamlPackages; [
      dune-configurator
    ];

    propagatedBuildInputs = with ocamlPackages; [
      ff-sig
      zarith
      ctypes
      bls12-381-gen
    ];

    doCheck = true;

    meta = {
      description = "Virtual package for BLS12-381 primitives";
      license = lib.licenses.mit;
    };
  };


  bls12-381-unix = ocamlPackages.buildDunePackage {
    pname = "bls12-381-unix";
    version = "0.4.2";
    inherit src;

    checkInputs = with ocamlPackages; [
      alcotest
      ff-pbt
    ];

    buildInputs = with ocamlPackages; [
      pkgs.rustc
      pkgs.cargo
      dune-configurator
    ];

    propagatedBuildInputs = with ocamlPackages; [
      ff-sig
      zarith
      ctypes
      bls12-381-gen
      bls12-381
      tezos-rust-libs
    ];

    OPAM_SWITCH_PREFIX = "${ocamlPackages.tezos-rust-libs}/lib/ocaml/${ocamlVersion}/site-lib";

    doCheck = true;

    meta = {
      description = "UNIX version of BLS12-381 primitives implementing the virtual package bls12-381";
      license = lib.licenses.mit;
    };
  };
}
