{ buildDunePackage, dune-configurator, cstruct, fmt, optint }:

buildDunePackage {
  pname = "uring";
  version = "0.4";

  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/ocaml-uring/archive/b95047500.tar.gz;
    sha256 = "1wacdsrlsh072m7cabbgrmiwbiyyx7alss8x305l5l5fqmfaz7ra";
  };

  postPatch = ''
    patchShebangs vendor/liburing/configure
    substituteInPlace lib/uring/dune --replace \
      '(run ./configure)' '(bash "./configure")'
  '';
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ cstruct fmt optint ];
}
