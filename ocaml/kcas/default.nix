{ buildDunePackage, domain-local-await }:

buildDunePackage {
  pname = "kcas";
  version = "0.3.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/kcas/releases/download/0.3.1/kcas-0.3.1.tbz;
    sha256 = "17l183wbwdsjjpf84q2lkbph530y8arg355a46zwy08djmnfdk1l";
  };
  propagatedBuildInputs = [ domain-local-await ];
}
