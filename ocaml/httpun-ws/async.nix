{
  buildDunePackage,
  httpun-ws,
  async,
  gluten-async,
  faraday-async,
  async_ssl,
  digestif,
}:

buildDunePackage {
  pname = "httpun-ws-async";
  inherit (httpun-ws) src version;

  propagatedBuildInputs = [
    httpun-ws
    async
    gluten-async
    faraday-async
    async_ssl
    digestif
  ];
}
