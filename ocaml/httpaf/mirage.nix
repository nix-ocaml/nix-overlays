{ buildDunePackage, conduit-mirage, httpaf, httpaf-lwt, gluten-mirage }:

buildDunePackage {
  inherit (httpaf) version src;
  pname = "httpaf-mirage";
  doCheck = false;
  propagatedBuildInputs = [ conduit-mirage httpaf-lwt gluten-mirage ];
}
