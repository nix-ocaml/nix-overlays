{ lib, buildDunePackage, websocketaf, graphql }:

buildDunePackage {
  pname = "subscriptions-transport-ws";
  version = "0.0.1-dev";
  useDune2 = true;
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-subscriptions-transport-ws/archive/f64a1b350cbdea98f62824429ab592c3a2031761.tar.gz;
    sha256 = "07p0n82xf63f1nc1d9q3k7b3a09cxzja01gabg39czaddjc9qh4c";
  };

  propagatedBuildInputs = [ websocketaf graphql ];

  meta = {
    license = lib.licenses.bsd3;
  };
}
