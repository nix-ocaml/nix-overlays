{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "tar";
  version = "1.1.0";
  src = builtins.fetchurl {
    url = https://github.com/mirage/ocaml-tar/releases/download/v1.1.0/tar-v1.1.0.tbz;
    sha256 = "13814vwydrl6y1cnn5mzlcvagna2kzad5wx0w55ar3q553hlr3n4";
  };

  buildInputs = [
    ppx_tools
  ];

  propagatedBuildInputs = [
    ppx_cstruct
    cstruct
    re
  ];

  meta = {
    description = "Decode and encode tar format files in pure OCaml";
    license = lib.licenses.isc;
  };
}
