{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "httpaf-lwt";
  inherit (httpaf) version src;
  propagatedBuildInputs = [ httpaf gluten-lwt lwt ];
}
