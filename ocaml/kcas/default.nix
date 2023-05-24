{ buildDunePackage, domain-local-await }:

buildDunePackage {
  pname = "kcas";
  version = "0.5.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/kcas/releases/download/0.5.1/kcas-0.5.1.tbz;
    sha256 = "1rhwhwy76vrv69frqyqya53nn4wf5py3hb0in7fr6x3dzyj7j6vl";
  };
  propagatedBuildInputs = [ domain-local-await ];
}
