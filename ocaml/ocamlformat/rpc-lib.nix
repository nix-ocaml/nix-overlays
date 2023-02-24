{ buildDunePackage, ocamlformat-lib, csexp }:

buildDunePackage {
  pname = "ocamlformat-rpc-lib";
  inherit (ocamlformat-lib) src version;

  minimumOCamlVersion = "4.08";
  strictDeps = true;

  propagatedBuildInputs = [ csexp ];
}
