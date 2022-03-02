{ buildDunePackage }:

buildDunePackage {
  pname = "domainslib";
  version = "0.5.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domainslib/archive/4ac01e870615e32291f0145a7cbdd5528b88ea59.tar.gz;
    sha256 = "1cqfxn4qf3jn18fscmzq8s4lqfzjsxk3yq4rqb2v1yy1wk0vp7gl";
  };
}
