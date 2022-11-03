{ buildDunePackage, dune-configurator, cstruct, fmt, optint }:

buildDunePackage {
  pname = "uring";
  version = "0.4";

  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/ocaml-uring/archive/385bf2e1.tar.gz;
    sha256 = "0bw4c5j9sy0biah447cdj2gbmn84dch9k7a95vwh8kyidnvwrwzh";
  };

  postPatch = ''
    patchShebangs vendor/liburing/configure
    substituteInPlace lib/uring/dune --replace \
      '(run ./configure)' '(bash "./configure")'
  '';
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ cstruct fmt optint ];
}
