{ lib, buildDunePackage, uri, ptime, astring }:

buildDunePackage {
  pname = "cookie";
  version = "0.1.8-dev";

  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-cookie/archive/95592ac37dc9209cf4f07544156aad7c3187dbab.tar.gz;
    sha256 = "0xy74b7ga3d2ssn05jiw9w8qpvi2kldki1jhjxka1shnfd6yb29a";
  };

  propagatedBuildInputs = [ uri ptime astring ];

  meta = {
    description = "Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
