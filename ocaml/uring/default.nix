{ fetchFromGitHub, buildDunePackage, dune-configurator, cstruct, fmt, optint }:

buildDunePackage {
  pname = "uring";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "ocaml-uring";
    rev = "b95047500";
    sha256 = "sha256-jsTE3wbBGoYOrB8bZsWjHuAJfHlm8wZLGtsL7lsyTAU=";
  };

  postPatch = ''
    patchShebangs vendor/liburing/configure
    substituteInPlace lib/uring/dune --replace \
      '(run ./configure)' '(bash "./configure")'
  '';
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ cstruct fmt optint ];
}
