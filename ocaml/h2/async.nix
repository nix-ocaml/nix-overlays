{ buildDunePackage, h2, async, gluten-async, faraday-async, async_ssl }:

buildDunePackage {
  inherit (h2) src version;
  pname = "h2-async";
  doCheck = false;

  propagatedBuildInputs = [ h2 async gluten-async faraday-async async_ssl ];
}
