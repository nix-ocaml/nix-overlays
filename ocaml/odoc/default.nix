{ ocamlPackages, pkgs, lib, beta_version ? false }:

with ocamlPackages;

buildDunePackage {
  pname = "odoc";
  version = "2.0.0-beta2";

  minimumOCamlVersion = "4.02";

  src = (if beta_version then
    builtins.fetchurl
      {
        url = "https://github.com/ocaml/odoc/archive/refs/tags/2.0.0-beta4.tar.gz";
        sha256 = "0qxd2dyk71ghj8689x7rkmryy0hdk2z5cgpdjszj9ky0fd28xq05";
      }
  else
    builtins.fetchurl {
      url = "https://github.com/ocaml/odoc/releases/download/1.5.2/odoc-1.5.2.tbz";
      sha256 = "0wa87h8q6izcc6rkzqn944vrb3hmc21lf0d0rmr8rhhbcvr66i6j";
    }
  );

  useDune2 = true;

  propagatedBuildInputs = [
    astring
    cmdliner
    cppo
    fpath
    result
    tyxml
    fmt
    logs
    re
    ocaml-migrate-parsetree-2-1
  ];

  checkInputs = [
    bisect_ppx
    ppx_expect
    ocaml-version
    lwt
    findlib
    alcotest
    markup
    yojson
    sexplib
    pkgs.jq
    pkgs.which
  ];

  # something is broken
  # doCheck = true;

  meta = {
    description = "A documentation generator for OCaml";
    license = lib.licenses.isc;
  };
}
