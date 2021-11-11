{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "redis";
  version = "0.4";
  src = builtins.fetchurl {
    url = https://github.com/0xffea/ocaml-redis/archive/0.4.tar.gz;
    sha256 = "1xia2dm0sr3mqlic1hvkglnv03ndbfxv18bhi2mfzpgpjcd9yl9a";
  };

  propagatedBuildInputs = [ uuidm re ];

  meta = {
    description = "Redis client";
    license = lib.licenses.bsd3;
  };
}
