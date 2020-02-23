{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "zed";
  version = "2.0.5";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/zed/releases/download/2.0.5/zed-2.0.5.tbz;
    sha256 = "0yjifjy0dyk3893kvj5dd0qpdpa4gii6n2dwr1lfbcl94f00p85k";
  };

  propagatedBuildInputs = [ camomile react charInfo_width ];
}
