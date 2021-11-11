{ buildDunePackage, archi, async }:

buildDunePackage {
  pname = "archi-async";
  inherit (archi) version src;
  propagatedBuildInputs = [ archi async ];
}
