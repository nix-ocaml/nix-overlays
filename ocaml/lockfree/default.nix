{ buildDunePackage }:

buildDunePackage {
  pname = "lockfree";
  version = "0.3.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lockfree/archive/015e8e9.tar.gz;
    sha256 = "1k99yd8130cc9969bqd15da0a372avg8bdgxj6bbr5d4bv8s3l39";
  };
}
