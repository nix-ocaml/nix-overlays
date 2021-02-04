{ ocamlPackages }:

with ocamlPackages;
let
  buildMenhir = args: buildDunePackage (rec {
    version = "20201201";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/repository/${version}/archive.tar.gz";
      sha256 = "1nw8l1rr4wila795g9cg5d3sakb7d3mldgp186r1iyjy74hfwxjb";
    };
    useDune2 = true;
  } // args);

in
{
  menhirSdk = buildMenhir {
    pname = "menhirSdk";
  };

  menhirLib = buildMenhir {
    pname = "menhirLib";
  };

  menhir = buildMenhir {
    pname = "menhir";
    propagatedBuildInputs = [ menhirLib menhirSdk ];
  };
}
