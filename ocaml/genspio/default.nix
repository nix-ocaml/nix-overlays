{ ocamlPackages, lib }:

ocamlPackages.buildDunePackage {
  pname = "genspio";
  version = "0.4-dev";
  src = builtins.fetchurl {
    url = https://github.com/hammerlab/genspio/archive/f270fb296cebcf25e2ea89a7929a274c03ae9e6e.tar.gz;
    sha256 = "1iwyi6hafqh2g3qqcyjwwxyxmx28w61jymis8by5b6azz5dkbf39";
  };

  propagatedBuildInputs = with ocamlPackages; [
    base
    fmt
  ];

  doCheck = true;

  meta = {
    description = "Typed EDSL to generate POSIX Shell scripts";
    license = lib.licenses.asl20;
  };
}
