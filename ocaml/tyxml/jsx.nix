{ lib, buildDunePackage, tyxml, tyxml-syntax, ppxlib, reason, alcotest }:

buildDunePackage {
  inherit (tyxml) src version;
  pname = "tyxml-jsx";

  propagatedBuildInputs = [ tyxml tyxml-syntax ppxlib reason ];

  checkInputs = [ alcotest ];

  # Tests are broken for some reason (pun intended)
  # doCheck = true;

  meta = {
    description = "JSX syntax to write TyXML documents";
    license = lib.licenses.lgpl21;
  };

}
