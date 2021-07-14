{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;


stdenv.mkDerivation
rec {
  pname = "ocaml${ocaml.version}-zarith";
  version = "1.11";
  src = builtins.fetchurl {
    url = "https://github.com/ocaml/Zarith/archive/refs/tags/release-1.11.tar.gz";
    sha256 = "111n33flg4aq5xp5jfksqm4yyz6mzxx9ps9a4yl0dz8h189az5pr";
  };

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = [ ocaml findlib pkgs.perl ];
  propagatedBuildInputs = with pkgs; [ gmp ];

  patchPhase = "patchShebangs ./z_pp.pl";
  dontAddPrefix = true;
  configureFlags = [ "-installdir ${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib" ];

  preInstall = "mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs";

  meta = with lib; {
    description = "Fast, arbitrary precision OCaml integers";
    homepage = "http://forge.ocamlcore.org/projects/zarith";
    license = licenses.lgpl2;
    inherit (ocaml.meta) platforms;
  };
}
