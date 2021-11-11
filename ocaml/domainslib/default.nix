{ buildDunePackage }:

buildDunePackage {
  pname = "domainslib";
  version = "0.2.2-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domainslib/archive/8aa79bbc0ceeeb373fc5a1bc946705bd8235a20d.tar.gz;
    sha256 = "0m17zyhxwkj7ffzai2wvin5fm3iq2mmx0mi2l3ia4dsx6ksv9p3f";
  };
}
