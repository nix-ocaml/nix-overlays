{ ocamlPackages }:

with ocamlPackages;

buildDunePackage (rec {
  pname = "base64";
  version = "3.3.0";

  nativeBuildInputs = [ dune-configurator ];
  buildInputs = [ dune-configurator bos ];
  checkInputs =  [ alcotest ];

  doCheck = false;
  useDune2 = true;

  # This installs a `dune-package` file in the destdir that messes with the
  # dune version checks, causing other packages to require Dune 2
  postInstall = ''
    rm $OCAMLFIND_DESTDIR/base64/dune-package
  '';
  src = builtins.fetchurl {
    url = "https://github.com/mirage/ocaml-base64/releases/download/v${version}/base64-v${version}.tbz";
    sha256 = "1k1m1z55wkkjy597v8qlbl4i2n75jh7h365mj1kdkk19y0s17s9s";
  };
})

