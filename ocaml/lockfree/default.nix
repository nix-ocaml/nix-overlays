{ buildDunePackage }:

buildDunePackage {
  pname = "lockfree";
  version = "0.3.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lockfree/archive/e1396b0.tar.gz;
    sha256 = "0nsdi3r1mnfls1ja3gq41cgclk2s8ffqcv687xixwkym8dzpmpgn";
  };
}
