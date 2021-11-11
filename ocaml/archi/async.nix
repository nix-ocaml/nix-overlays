{ ocamlPackages }:

with ocamlPackages;
buildDunePackage {
  pname = "archi-async";
  inherit (archi) version src;
  propagatedBuildInputs = [ archi async ];
}
