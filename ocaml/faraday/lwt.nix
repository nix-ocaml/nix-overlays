{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-lwt";
  propagatedBuildInputs = [ faraday lwt ];
}
