{ oself, osuper }:

with oself;

{
  hkdf = osuper.hkdf.overrideAttrs (o: {
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/hkdf/dune-package
    '';
  });

  tls = osuper.tls.overrideAttrs (o: {
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/tls/dune-package
    '';
  });

  tls-mirage = buildDunePackage {
    pname = "tls-mirage";
    version = osuper.tls.version;
    src = osuper.tls.src;
    useDune2 = true;
    postInstall = ''
      rm $OCAMLFIND_DESTDIR/tls-mirage/dune-package
    '';
    propagatedBuildInputs = [
      tls
      x509
      fmt
      lwt4
      mirage-flow
      mirage-kv
      mirage-clock
      ptime
      mirage-crypto
      mirage-crypto-pk
    ];
  };
}

