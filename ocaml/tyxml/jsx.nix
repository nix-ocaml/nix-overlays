{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  inherit (tyxml) src version;
  pname = "tyxml-jsx";

  propagatedBuildInputs = [
    tyxml
    tyxml-syntax
    ppx_tools_versioned
    reason
  ];

  meta = {
    description = "JSX syntax to write TyXML documents";
    license = lib.licenses.lgpl21;
  };

}
