{ osuper }:

let
  src = builtins.fetchurl {
    url = https://github.com/mirage/mirage-crypto/releases/download/v0.8.0/mirage-crypto-v0.8.0.tbz;
    sha256 = "1wb2923v17z179v866ragil0r601w5b3kvpnbkmkwlijp4i5grih";
  };

  overrideMirageCrypto = pname: osuper."${pname}".overrideAttrs (_: {
    inherit src;

    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${pname}/dune-package
    '';
  });
in

  {
    mirage-crypto = overrideMirageCrypto "mirage-crypto";
    mirage-crypto-pk = overrideMirageCrypto "mirage-crypto-pk";
    mirage-crypto-rng = overrideMirageCrypto "mirage-crypto-rng";
  }

