{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "httpun-ws";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "9418a9a192616955532498c454702275a0795643";
    hash = "sha256-YtEMtgCBWPg6uBJDVAVMzLhOlA8LvQoEVR4NSCEI/fk=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
