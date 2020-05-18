{ osuper, oself }:

with oself;

let
  src = builtins.fetchurl {
    url = "https://github.com/mirage/mirage-crypto/releases/download/v0.7.0/mirage-crypto-v0.7.0.tbz";
    sha256 = "0k7kllv3bh192yj6p9dk2z81r56w7x2kyr46pxygb5gnhqqxcncf";
  };
  overridePostInstall = pname: {
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${pname}/dune-package
    '';
  };
in rec {
  mirage-crypto = osuper.mirage-crypto.overrideAttrs (_: { inherit src; } // overridePostInstall "mirage-crypto");

  mirage-crypto-rng =
  let pname = "mirage-crypto-rng";
  in
  buildDunePackage (rec {
    inherit pname src;
    version = "0.7.0";
    useDune2 = true;

    propagatedBuildInputs = [
      cstruct
      mirage-runtime
      lwt4
      mirage-crypto
      dune-configurator
      duration
      logs
      mtime
      mirage-time
      mirage-clock
    ];
  } // (overridePostInstall pname));

  mirage-crypto-pk = osuper.mirage-crypto-pk.overrideAttrs (_: overridePostInstall "mirage-crypto-pk");
}

