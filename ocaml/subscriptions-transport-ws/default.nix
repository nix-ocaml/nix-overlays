{ lib, buildDunePackage, websocketaf, graphql }:

buildDunePackage {
  pname = "subscriptions-transport-ws";
  version = "0.0.1-dev";
  useDune2 = true;
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-subscriptions-transport-ws/archive/f64a1b350cbdea98f62824429ab592c3a2031761.tar.gz;
    sha256 = "0rxwjb2fjs99phy8fpp4vkp8y8ryfjkf920afns38lahdc06mifp";
  };

  propagatedBuildInputs = [ websocketaf graphql ];

  meta = {
    license = lib.licenses.bsd3;
  };
}
