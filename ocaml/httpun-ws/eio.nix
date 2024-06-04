{ buildDunePackage, httpun-ws, gluten-eio, eio, digestif }:

buildDunePackage {
  pname = "httpun-ws-eio";
  inherit (httpun-ws) src version;
  propagatedBuildInputs = [ httpun-ws gluten-eio eio digestif ];
}
