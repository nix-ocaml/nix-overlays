{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "archi-lwt";
  inherit (archi) version src;
  propagatedBuildInputs = [ archi lwt ];
}
