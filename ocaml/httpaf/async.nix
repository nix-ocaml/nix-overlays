{ buildDunePackage
, httpaf
, async
, gluten-async
, faraday-async
, async_ssl
}:

buildDunePackage {
  inherit (httpaf) version src;
  pname = "httpaf-async";
  doCheck = false;
  propagatedBuildInputs = [
    httpaf
    async
    gluten-async
    faraday-async
    async_ssl
  ];
}
