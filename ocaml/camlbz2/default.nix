{ autoconf, automake, bzip2, stdenv, ocamlPackages }:

with ocamlPackages;

stdenv.mkDerivation {
  name = "camlbz2";
  version = "0.7.0";
  src = builtins.fetchurl {
    url = https://gitlab.com/irill/camlbz2/-/archive/0.7.0/camlbz2-0.7.0.tar.gz;
    sha256 = "0yn6mfyq7wxbikczx5cap5j8zyjfgmi835z7m5vyn3wg69ys69gp";
  };

  nativeBuildInputs = [ autoconf automake ];
  buildInputs = [ ocaml findlib bzip2 ];
  preConfigure = ''
    aclocal -I .
    autoconf
  '';

  createFindlibDestdir = true;
}
