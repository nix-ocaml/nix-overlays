{ osuper }:

let
  overrideMirageCrypto = pname: osuper."${pname}".overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/mirage-crypto/archive/9c13805b6c3ca121715d92705e5706d43cb63281.tar.gz;
      sha256 = "1zyzmxg8iar4hxvmb5fyh75k10bla61rw5yhqqcx6j35fnj1yhpl";
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

