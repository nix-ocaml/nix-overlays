{ buildDunePackage, landmarks, ppxlib }:

buildDunePackage rec {
  pname = "landmarks-ppx";
  inherit (landmarks) version src;
  propagatedBuildInputs = [ ppxlib landmarks ];
}
