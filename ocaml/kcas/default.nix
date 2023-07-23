{ buildDunePackage, domain-local-await, domain-local-timeout }:

buildDunePackage {
  pname = "kcas";
  version = "0.6.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/kcas/releases/download/0.6.1/kcas-0.6.1.tbz;
    sha256 = "0qid0kqaz3aczs76vgjca8h73njs4d312xn074hiakf81fw7qxmv";
  };
  propagatedBuildInputs = [ domain-local-await domain-local-timeout ];
}
