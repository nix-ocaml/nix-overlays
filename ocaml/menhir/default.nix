{ ocamlPackages }:

with ocamlPackages;

let
  buildMenhir = args: buildDune2Package ({
    version = "20200123";
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/menhir/repository/20200123/archive.tar.gz;
      sha256 = "1x19mplzk5kgqgpdggsgl4hfg9rs7wzybwaf7fj7x9qxvqmnndfv";
    };
  } // args);

in rec {
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
