{ lib, stdenv, fetchFromGitHub, buildDunePackage, ocaml, findlib, cppo }:


buildDunePackage rec {
  pname = "ppx_tools";
  version = "6.5";
  src = builtins.fetchurl {
    url = "https://github.com/ocaml-ppx/ppx_tools/releases/download/${version}/ppx_tools-${version}.tar.gz";
    sha256 = "14lma1i5h7h8425f28qlnypycfb68sp0wqmip6ld7zr22rrb40l2";
  };
  nativeBuildInputs = [ cppo ];
  useDune2 = true;
  meta = with lib; {
    description = "Tools for authors of ppx rewriters";
    homepage = "https://www.lexifi.com/ppx_tools";
    license = licenses.mit;
  };
}
