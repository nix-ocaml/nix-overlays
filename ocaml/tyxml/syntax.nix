{ lib, buildDunePackage, ppxlib, uutf, re, tyxml, alcotest }:

buildDunePackage {
  pname = "tyxml-syntax";
  inherit (tyxml) src version;

  postPatch = ''
    substituteInPlace syntax/name_convention.ml \
      --replace "Char.lowercase "  "Char.lowercase_ascii " \
      --replace "Char.uppercase "  "Char.uppercase_ascii "
  '';

  propagatedBuildInputs = [ ppxlib uutf re ];

  checkInputs = [ alcotest ];

  doCheck = true;

  meta = {
    description = "Common layer for the JSX and PPX syntaxes for Tyxml";
    license = lib.licenses.lgpl21;
  };
}
