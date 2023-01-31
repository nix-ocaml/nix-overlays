{ lib, fetchFromGitHub, buildDunePackage, websocketaf, graphql }:

buildDunePackage {
  pname = "subscriptions-transport-ws";
  version = "0.0.1-dev";
  useDune2 = true;

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-subscriptions-transport-ws";
    rev = "f64a1b350cbdea98f62824429ab592c3a2031761";
    sha256 = "sha256-15zAWaYOM8ufYc6Ad5esXbqFHNGXZXBX2WrRZhsi0wI=";
  };

  propagatedBuildInputs = [ websocketaf graphql ];

  meta = {
    license = lib.licenses.bsd3;
  };
}
