{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "nocrypto";
  version = "0.5.5-dev";
  src = fetchFromGitHub {
    owner = "mirleft";
    repo = "ocaml-nocrypto";
    rev = "80b7b4b9bd1ccfba3ec93d85cd82bfb3dc10f887";
    sha256 = "1dw19lwasyafljqajx8diiqi01zdv5a8x90l81br457a297fzk8h";
  };

  doCheck = true;
  nativeBuildInputs = [ cpuid ];
  propagatedBuildInputs = [ cstruct ocplib-endian zarith lwt4 ];
  buildInputs = [ ounit ];
}
