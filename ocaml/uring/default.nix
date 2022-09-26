{ buildDunePackage, dune-configurator, cstruct, fmt, optint }:

buildDunePackage {
  pname = "uring";
  version = "0.4";

  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/ocaml-uring/releases/download/v0.4/uring-0.4.tbz;
    sha256 = "0pwf26ddys1qy3gqwsqsji8bmg959azab2lysyz2d5hmnh21jcks";
  };

  postPatch = ''
    patchShebangs vendor/liburing/configure
    substituteInPlace lib/uring/dune --replace \
      '(run ./configure)' '(bash "./configure")'
  '';
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ cstruct fmt optint ];
}
