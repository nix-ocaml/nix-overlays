{ buildDunePackage, websocketaf, gluten-eio, eio, digestif }:

buildDunePackage {
  pname = "websocketaf-eio";
  inherit (websocketaf) src version;
  propagatedBuildInputs = [ websocketaf gluten-eio eio digestif ];
}
