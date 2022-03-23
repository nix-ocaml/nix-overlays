{ lib, buildDunePackage, tyxml, tyxml-syntax, ppxlib, reason, alcotest }:

buildDunePackage {
  inherit (tyxml) src version;
  pname = "tyxml-jsx";

  postPatch = ''
    substituteInPlace jsx/tyxml_jsx.ml \
      --replace "Char.lowercase "  "Char.lowercase_ascii " \
      --replace "Char.uppercase "  "Char.uppercase_ascii " \
      --replace "String.lowercase "  "String.lowercase_ascii " \
      --replace "String.uppercase "  "String.uppercase_ascii "
  '';

  propagatedBuildInputs = [ tyxml tyxml-syntax ppxlib reason ];

  checkInputs = [ alcotest ];

  # Tests are broken for some reason (pun intended)
  # doCheck = true;

  meta = {
    description = "JSX syntax to write TyXML documents";
    license = lib.licenses.lgpl21;
  };

}
