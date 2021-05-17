{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "tar-unix";
  version = "1.1.0";
  src = builtins.fetchurl {
    url = https://github.com/mirage/ocaml-tar/releases/download/v1.1.0/tar-v1.1.0.tbz;
    sha256 = "13814vwydrl6y1cnn5mzlcvagna2kzad5wx0w55ar3q553hlr3n4";
  };

  propagatedBuildInputs = [
    tar
    cstruct
    cstruct-lwt
    re
    lwt
  ];

  meta = {
    description = "Decode and encode tar format files from Unix";
    license = lib.licenses.isc;
  };
}
