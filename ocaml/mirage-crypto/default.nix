{ osuper, oself }:

with oself;

let
  overridePostInstall = pname: {
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${pname}/dune-package
    '';
  };
in rec {
  mirage-crypto = osuper.mirage-crypto.overrideAttrs (_: overridePostInstall "mirage-crypto");

  mirage-crypto-rng = osuper.mirage-crypto-rng.overrideAttrs (_: overridePostInstall "mirage-crypto-rng");

  mirage-crypto-entropy =
  let pname = "mirage-crypto-entropy";
  in
  buildDunePackage (rec {
    inherit pname;
    version = "0.6.2";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-crypto/releases/download/v${version}/mirage-crypto-v${version}.tbz";
      sha256 = "08xq49cxn66yi0gfajzi8czcxfx24rd191rvf7s10wfkz304sa72";
    };
    useDune2 = true;

    propagatedBuildInputs = [
      cstruct
      mirage-runtime
      lwt4
      mirage-crypto
      mirage-crypto-rng
    ];
  } // (overridePostInstall pname));

  mirage-crypto-pk = osuper.mirage-crypto-pk.overrideAttrs (_: overridePostInstall "mirage-crypto-pk");
}

