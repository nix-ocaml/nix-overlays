{ lib, stdenv, fetchFromGitHub, buildDunePackage, ocaml, findlib, cppo }:


buildDunePackage rec {
  pname = "ppx_tools";
  version = "6.6";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ppx_tools/releases/download/6.6/ppx_tools-6.6.tar.gz;
    sha256 = "07b5ryvp8qmij49v2xkpfck6vpj28lgrw7pwfnvxpnvmskfgcf3s";
  };
  nativeBuildInputs = [ cppo ];
  useDune2 = true;
  meta = with lib; {
    description = "Tools for authors of ppx rewriters";
    homepage = "https://www.lexifi.com/ppx_tools";
    license = licenses.mit;
  };
}
