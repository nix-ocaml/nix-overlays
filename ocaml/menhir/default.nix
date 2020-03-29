{ ocamlPackages }:

with ocamlPackages;

let
  buildMenhir = args: buildDunePackage ({
    version = "20200211";
    src = builtins.fetchurl {
      url = https://gitlab.inria.fr/fpottier/menhir/repository/20200211/archive.tar.gz;
      sha256 = "1mls0w2g0mbb1n0yg0f36qbm4xlcri57cdrjy0lhnspmzxmj52f8";
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
