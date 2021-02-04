{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-lwt-unix";
  propagatedBuildInputs = [ faraday-lwt ];
}
