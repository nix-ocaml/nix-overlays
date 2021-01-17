{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/ocsigen/tyxml/archive/4.4.0.tar.gz;
  sha256 = "1yhf09vpnhw7mp1iiq9rrf1igsviashyqf8vxv2g7wxpn0nrshfz";
};

in
{
  tyxml = ocamlPackages.buildDunePackage {
    pname = "tyxml";
    version = "4.4.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      seq
      uutf
      re
    ];

    meta = {
      description = "TyXML is a library for building correct HTML and SVG documents";
      license = stdenv.lib.licenses.lgpl21;
    };
  };

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
      license = stdenv.lib.licenses.lgpl21;
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
      license = stdenv.lib.licenses.lgpl21;
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
      license = stdenv.lib.licenses.lgpl21;
    };
  };
}
