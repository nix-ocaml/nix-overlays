{ ocamlPackages }:

with ocamlPackages;
let
  buildMenhir = args: buildDunePackage (rec {
    version = "20210310";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/-/archive/${version}/archive.tar.gz";
      sha256 = "168qd2r6aiic2l5n7gxx085avx3afsrs2vjgwzmkkayix4nak5pf";
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
