{ ocamlPackages }:

with ocamlPackages;

let
  buildMenhir = args: buildDunePackage (rec {
    version = "20200624";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/repository/${version}/archive.tar.gz";
      sha256 = "13m5hy1lvcpiybc1r15cfd1n7gnpbybly8if7lg6fc7j5bhp0df1";
    };

    useDune2 = true;

    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${args.pname}/dune-package
    '';
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
