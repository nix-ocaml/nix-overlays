{ lib, stdenv, fetchFromGitHub, buildDunePackage, ocaml, findlib, cppo }:

buildDunePackage rec {
  pname = "ppx_tools";
  version = "6.4";
  src = fetchFromGitHub {
    owner = "alainfrisch";
    repo = pname;
    rev = version;
    sha256 = "15v7yfv6gyp8lzlgwi9garz10wpg34dk4072jdv19n6v20zfg7n1";
  };
  nativeBuildInputs = [ cppo ];
  useDune2 = true;
  meta = with lib; {
    description = "Tools for authors of ppx rewriters";
    homepage = "https://www.lexifi.com/ppx_tools";
    license = licenses.mit;
    maintainers = with maintainers; [ vbgl ];
  };
}
