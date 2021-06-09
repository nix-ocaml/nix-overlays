{ lib, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/dannywillems/ocaml-ff/-/archive/0.6.1/ocaml-ff-0.6.1.tar.gz;
    sha256 = "0nxwb2bi0qdshyjzkh5zld5llhrp77b6s7lv14475qz8b57gq36w";
  };

in

{
  ff-pbt = ocamlPackages.buildDunePackage {
    pname = "ff-pbt";
    version = "0.6.1";
    inherit src;

    checkInputs = with ocamlPackages; [
      alcotest
    ];

    propagatedBuildInputs = with ocamlPackages; [
      zarith
      ff-sig
    ];

    doCheck = true;

    meta = {
      description = "Property based testing library for finite fields over the package ff-sig";
      license = lib.licenses.mit;
    };
  };


  ff-sig = ocamlPackages.buildDunePackage {
    pname = "ff-sig";
    version = "0.6.1";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      zarith
    ];

    # tests are broken
    doCheck = true;

    meta = {
      description = "Minimal finite field signatures";
      license = lib.licenses.mit;
    };
  };

  ff = ocamlPackages.buildDunePackage {
    pname = "ff";
    version = "0.6.1";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      zarith
      ff-sig
    ];

    checkInputs = with ocamlPackages; [
      alcotest
      ff-pbt
      bisect_ppx
    ];

    # tests are broken
    doCheck = true;

    meta = {
      description = "Minimal finite field signatures";
      license = lib.licenses.mit;
    };
  };
}
