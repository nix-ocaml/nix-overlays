{ oself, osuper }:

with oself;

{
  tls-mirage = buildDunePackage {
    pname = "tls-mirage";
    version = osuper.tls.version;
    src = osuper.tls.src;
    useDune2 = true;
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

