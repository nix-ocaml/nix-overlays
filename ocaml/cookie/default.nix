{ lib, buildDunePackage, uri, ptime, astring }:

buildDunePackage {
  pname = "cookie";
  version = "0.1.8-dev";

  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-cookie/archive/95592ac37dc9209cf4f07544156aad7c3187dbab.tar.gz;
    sha256 = "02rmanzjbxps2ax3546pd3jpzx88kcb9zlyyza920fvnavhk3g10";
  };

  propagatedBuildInputs = [ uri ptime astring ];

  meta = {
    description = "Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
