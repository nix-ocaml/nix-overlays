{ ocamlPackages }:

with ocamlPackages;

let
  buildMenhir = args: buildDunePackage (rec {
    version = "20200612";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/repository/${version}/archive.tar.gz";
      sha256 = "0d67y61vjrgpcwlq51xnq9hb9ji115lh1wzhsik0lx0rgwjlzdpb";
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
