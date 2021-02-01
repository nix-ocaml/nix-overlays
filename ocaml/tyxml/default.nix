{ ocamlPackages, lib }:

with ocamlPackages;
let src = ocamlPackages.tyxml.src;

in
{
  tyxml-syntax = ocamlPackages.buildDunePackage {
    pname = "tyxml-syntax";
    version = "4.4.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      ppx_tools_versioned
      uutf
      re
    ];

    meta = {
      description = "Common layer for the JSX and PPX syntaxes for Tyxml";
      license = lib.licenses.lgpl21;
    };
  };

  tyxml-jsx = ocamlPackages.buildDunePackage {
    pname = "tyxml-jsx";
    version = "4.4.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      tyxml
      tyxml-syntax
      ppx_tools_versioned
      reason
    ];

    meta = {
      description = "JSX syntax to write TyXML documents";
      license = lib.licenses.lgpl21;
    };
  };

  tyxml-ppx = ocamlPackages.buildDunePackage {
    pname = "tyxml-ppx";
    version = "4.4.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
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
  };
}
