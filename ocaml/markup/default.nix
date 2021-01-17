{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/aantron/markup.ml/archive/1.0.0.tar.gz;
  sha256 = "09pd7myjamvzmapmf2j20q01zqfym43wmagmbs1nylf6wfhwg0ha";
};

in
{
  markup = ocamlPackages.buildDunePackage {
    pname = "markup";
    version = "1.0.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      uchar
      uutf
    ];

    meta = {
      description = "Error-recovering functional HTML5 and XML parsers and writers";
      license = stdenv.lib.licenses.mit;
    };
  };


  markup-lwt = ocamlPackages.buildDunePackage {
    pname = "markup-lwt";
    version = "1.0.0";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      markup
      lwt
      base-unix
    ];

    meta = {
      description = "Adapter between Markup.ml and Lwt";
      license = stdenv.lib.licenses.mit;
    };
  };
}
