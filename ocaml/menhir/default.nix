{ ocamlPackages }:

with ocamlPackages;

let
  buildMenhir = args: buildDunePackage (rec {
    version = "20200525";
    src = builtins.fetchurl {
      url = "https://gitlab.inria.fr/fpottier/menhir/repository/${version}/archive.tar.gz";
      sha256 = "1ic1diyknf9y6alx8zl38h4x4b4hx1ypwn7jaffr5gxvf5w55nh0";
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
