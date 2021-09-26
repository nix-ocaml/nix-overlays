{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (reason) src version;
  pname = "rtop";
  buildInputs = [ cppo ];
  propagatedBuildInputs = [ utop reason ];
}
