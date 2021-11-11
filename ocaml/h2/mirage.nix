{ buildDunePackage, conduit-mirage, h2, h2-lwt, gluten-mirage }:

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-mirage";
  doCheck = false;
  propagatedBuildInputs = [ conduit-mirage h2-lwt gluten-mirage ];
}
