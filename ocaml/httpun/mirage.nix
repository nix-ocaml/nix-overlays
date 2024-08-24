{ buildDunePackage, httpun, httpun-lwt, gluten-mirage }:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-mirage";
  doCheck = false;
  propagatedBuildInputs = [ httpun-lwt gluten-mirage ];
}
