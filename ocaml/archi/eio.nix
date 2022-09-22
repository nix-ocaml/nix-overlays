{ buildDunePackage, archi, eio }:

buildDunePackage {
  pname = "archi-eio";
  inherit (archi) version src;
  propagatedBuildInputs = [ archi eio ];
}
