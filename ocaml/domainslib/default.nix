{ buildDunePackage }:

buildDunePackage {
  pname = "domainslib";
  version = "0.5.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domainslib/archive/15f04f3.tar.gz;
    sha256 = "03hwqjkfiz74z6dxi3af7crwak2231s7x9smjpgrv50qhh69liip";
  };
}
