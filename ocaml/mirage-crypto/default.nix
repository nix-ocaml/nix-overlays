{ ocamlPackages }:

with ocamlPackages;

let
  buildMirageCrypto = args: buildDunePackage (rec {
    version = "0.6.2";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-crypto/releases/download/v${version}/mirage-crypto-v${version}.tbz";
      sha256 = "08xq49cxn66yi0gfajzi8czcxfx24rd191rvf7s10wfkz304sa72";
    };
    useDune2 = true;
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${args.pname}/dune-package
    '';
  } // args);
in rec {
  mirage-crypto = buildMirageCrypto {
    pname = "mirage-crypto";
    propagatedBuildInputs = [ dune-configurator cpuid cstruct ocplib-endian ];
  };

  mirage-crypto-rng = buildMirageCrypto {
    pname = "mirage-crypto-rng";
    propagatedBuildInputs = [ dune-configurator cstruct mirage-crypto ];
  };

  mirage-crypto-entropy = buildMirageCrypto {
    pname = "mirage-crypto-entropy";
    propagatedBuildInputs = [
      cstruct
      mirage-runtime
      lwt4
      mirage-crypto
      mirage-crypto-rng
    ];
  };

  mirage-crypto-pk = buildMirageCrypto {
    pname = "mirage-crypto-pk";
    propagatedBuildInputs = [
      cstruct
      mirage-crypto
      mirage-crypto-rng
      sexplib
      ppx_sexp_conv
      zarith
      eqaf
      rresult
    ];
  };
}

