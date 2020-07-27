{ osuper }:

let
  overrideMirageCrypto = pname: osuper."${pname}".overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/mirage/mirage-crypto/releases/download/v0.8.3/mirage-crypto-v0.8.3.tbz;
      sha256 = "08rmhjrk046nnhbdk16vg7w7ink4bj6yq9dsjcky5psn982aqiwi";
    };
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

