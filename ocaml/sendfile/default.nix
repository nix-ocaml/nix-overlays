{ buildDunePackage }:

buildDunePackage {
  pname = "sendfile";
  version = "dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-sendfile/archive/75c37fc.tar.gz;
    sha256 = "0nfsyi6r22yrdm1i1la23775dfm5cingawwrl2rfhsdzx0s46j26";
  };
}
