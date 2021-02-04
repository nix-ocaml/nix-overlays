{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "tyxml-ppx";
  inherit (tyxml) src version;
  propagatedBuildInputs = [
    tyxml
    tyxml-syntax
    ppx_tools_versioned
    reason
    markup
  ];

  meta = {
    description = "JSX syntax to write TyXML documents";
    license = lib.licenses.lgpl21;
  };
}
