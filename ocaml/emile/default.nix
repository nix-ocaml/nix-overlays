{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "emile";
  version = "0.5.6";
  src = builtins.fetchurl {
    url = https://github.com/dinosaure/emile/releases/download/v1.1/emile-v1.1.tbz;
    sha256 = "0r1141makr0b900aby1gn0fccjv1qcqgyxib3bzq8fxmjqwjan8p";
  };

  propagatedBuildInputs = [ angstrom ipaddr base64 pecu uutf ];
  checkInputs = [alcotest];

  meta = {
    description = "Cross-platform asynchronous I/O and system calls ";
    license = stdenv.lib.licenses.mit;
  };
}
