{ buildDunePackage
, httpun
, async
, gluten-async
, faraday-async
, async_ssl
}:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-async";
  doCheck = false;
  propagatedBuildInputs = [
    httpun
    async
    gluten-async
    faraday-async
    async_ssl
  ];
}
