{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "websocketaf-lwt";
  inherit (websocketaf) src version;
  propagatedBuildInputs = [ websocketaf gluten-lwt lwt digestif ];
}
