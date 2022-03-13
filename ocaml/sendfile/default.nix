{ buildDunePackage }:

buildDunePackage {
  pname = "sendfile";
  version = "dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-sendfile/archive/8e3d17f8e.tar.gz;
    sha256 = "19acd16a7y2kmkwxv07gricr3pxi5hqkjqaavcfnjxj5xv6qlv7f";
  };
}
