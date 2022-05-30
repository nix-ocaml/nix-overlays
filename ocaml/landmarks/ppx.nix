{ buildDunePackage, landmarks, ppxlib }:

buildDunePackage rec {
  pname = "landmarks-ppx";
  inherit (landmarks) version src patches;
  propagatedBuildInputs = [ ppxlib landmarks ];
}
