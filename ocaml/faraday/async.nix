{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-async";
  propagatedBuildInputs = [ faraday async core ];
}
