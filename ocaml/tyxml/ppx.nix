{ lib
, buildDunePackage
, tyxml
, tyxml-syntax
, ppxlib
, reason
, markup
, alcotest
}:

buildDunePackage {
  pname = "tyxml-ppx";
  inherit (tyxml) src version;

  postPatch = ''
    substituteInPlace ppx/tyxml_ppx.ml \
      --replace "String.capitalize "  "String.capitalize_ascii "
  '';

  propagatedBuildInputs = [ tyxml tyxml-syntax ppxlib reason markup ];

  checkInputs = [ alcotest ];
  doCheck = true;

  meta = {
    description = "JSX syntax to write TyXML documents";
    license = lib.licenses.lgpl21;
  };
}
