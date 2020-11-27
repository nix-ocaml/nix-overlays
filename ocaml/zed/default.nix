{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "zed";
  version = "3.1.0";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/zed/archive/3.1.0.tar.gz;
    sha256 = "1z95fs49hi00xy078a83m0vfdqwjb5953rwr15lfpirldi4v11y3";
  };

  propagatedBuildInputs = [ camomile react charInfo_width ];
}
