{ buildDunePackage, domain-local-await }:

buildDunePackage {
  pname = "kcas";
  version = "0.3.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/kcas/releases/download/0.4.0/kcas-0.4.0.tbz;
    sha256 = "1s2ivd8mn54nyn4jpjpld95ni436hail90dsvv41yx6zpd1vdyqm";
  };
  propagatedBuildInputs = [ domain-local-await ];
}
