{ buildDunePackage
, websocketaf
, async
, gluten-async
, faraday-async
, async_ssl
, digestif
}:

buildDunePackage {
  pname = "websocketaf-async";
  inherit (websocketaf) src version;

  propagatedBuildInputs = [
    websocketaf
    async
    gluten-async
    faraday-async
    async_ssl
    digestif
  ];
}
