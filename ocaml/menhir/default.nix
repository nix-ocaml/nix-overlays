{ ocamlPackages }:

with ocamlPackages;
let
  buildMenhir = args: buildDunePackage (rec {
    version = "20201216";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/repository/${version}/archive.tar.gz";
      sha256 = "05fpg5c83a6q0q12kd2ll069pg80yd91s4rzx3742ard3l2aml8z";
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
