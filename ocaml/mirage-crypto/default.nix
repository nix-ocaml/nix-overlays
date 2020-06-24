{ osuper }:

let
  overrideMirageCrypto = pname: osuper."${pname}".overrideAttrs (_: {
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

