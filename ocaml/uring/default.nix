{ fetchFromGitHub, buildDunePackage, dune-configurator, cstruct, fmt, optint }:

buildDunePackage {
  pname = "uring";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "ocaml-uring";
    rev = "v0.5";
    sha256 = "sha256-Jc17Myc/oUEYpwUVKlxYSNsAAXn3WuM5AqisFcBG/Xk=";
  };

  postPatch = ''
    patchShebangs vendor/liburing/configure
    substituteInPlace lib/uring/dune --replace \
      '(run ./configure)' '(bash "./configure")'
  '';
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ cstruct fmt optint ];
}
