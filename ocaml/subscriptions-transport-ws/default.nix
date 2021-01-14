{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/anmonteiro/ocaml-subscriptions-transport-ws/archive/f64a1b350cbdea98f62824429ab592c3a2031761.tar.gz;
  sha256 = "07p0n82xf63f1nc1d9q3k7b3a09cxzja01gabg39czaddjc9qh4c";
};

in
{
  subscriptions-transport-ws = ocamlPackages.buildDunePackage
    {
      pname = "subscriptions-transport-ws";
      version = "0.0.1-dev";
      useDune2 = true;
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        websocketaf
        graphql
      ];

      meta = {
        license = stdenv.lib.licenses.bsd3;
      };
    };
}
